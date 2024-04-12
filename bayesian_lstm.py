import pandas as pd
import numpy as np
import torch
import torch.nn as nn
import torch.optim as optim
from blitz.modules import BayesianLSTM
from blitz.utils import variational_estimator
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import matplotlib.pyplot as plt
from collections import deque

window_size = 21
# window_size = 20


def pre_processing(system_state):
    raw_data = "data/"+system_state+".csv"
    df = pd.read_csv(raw_data)
    df.head()
    data = df["data"]
    scaler = StandardScaler()
    data_arr = np.array(data).reshape(-1, 1)
    data = scaler.fit_transform(data_arr)
    data_unscaled = df["data"]

    # Split train and test data
    Xs, ys = create_timestamps_ds(data)
    X_train, X_test, y_train, y_test = train_test_split(Xs,
                                                        ys,
                                                        test_size=0.2,
                                                        random_state=42,
                                                        shuffle=False)

    # X_test = torch.randn((750, 21, 1))

    ds = torch.utils.data.TensorDataset(X_train, y_train)
    dataloader_train = torch.utils.data.DataLoader(ds, batch_size=8, shuffle=True)

    return scaler, dataloader_train, X_train, X_test, y_train, y_test, Xs, ys


def create_timestamps_ds(series, timestep_size=window_size):
    time_stamps = []
    labels = []
    aux_deque = deque(maxlen=timestep_size)

    # starting the timestep deque
    for i in range(timestep_size):
        aux_deque.append(0)

    # feed the timestamps list
    for i in range(len(series) - 1):
        aux_deque.append(series[i])
        time_stamps.append(list(aux_deque))

    # feed the labels lsit
    for i in range(len(series) - 1):
        labels.append(series[i + 1])

    assert len(time_stamps) == len(labels), "Something went wrong"

    # torch-tensoring it
    features = torch.tensor(np.array(time_stamps[timestep_size:])).float()
    labels = torch.tensor(np.array(labels[timestep_size:])).float()

    return features, labels


# CREATE NEURAL NETWORK (BAYESIAN LSTM)
@variational_estimator
class NN(nn.Module):
    def __init__(self):
        super(NN, self).__init__()
        self.lstm_1 = BayesianLSTM(1, 10, prior_sigma_1=1, prior_pi=1, posterior_rho_init=-3.0)
        self.linear = nn.Linear(10, 1)

    def forward(self, x):
        x_, _ = self.lstm_1(x)

        # gathering only the latent end-of-sequence for the linear layer
        x_ = x_[:, -1, :]
        x_ = self.linear(x_)
        return x_


def train_lstm(system_state, net, X_train, X_test, y_test, dataloader_train):

    criterion = nn.MSELoss()
    optimizer = optim.Adam(net.parameters(), lr=0.001)

    iteration = 0
    for epoch in range(10):
        for i, (datapoints, labels) in enumerate(dataloader_train):

            optimizer.zero_grad()

            loss = net.sample_elbo(inputs=datapoints,
                                   labels=labels,
                                   criterion=criterion,
                                   sample_nbr=3,
                                   complexity_cost_weight=1 / X_train.shape[0])
            loss.backward()
            optimizer.step()

            iteration += 1
            if iteration % 250 == 0:
                preds_test = net(X_test)[:, 0].unsqueeze(1)
                loss_test = criterion(preds_test, y_test)
                print("Iteration: {} Val-loss: {:.4f}".format(str(iteration), loss_test))
    torch.save(net, 'parameters\lstm_param_'+system_state)


def prediction(X_test, X_train, Xs, scaler, future_length, net, sample_nbr=10):
    global window_size
    # creating auxiliar variables for future prediction
    preds_test = []
    test_begin = X_test[0:1, :, :]
    test_deque = deque(test_begin[0, :, 0].tolist(), maxlen=window_size)

    idx_pred = np.arange(len(X_train), len(Xs))

    # predict it and append to list


    for i in range(len(X_test)):
        # print(i)
        as_net_input = torch.tensor(test_deque).unsqueeze(0).unsqueeze(2)
        pred = [net(as_net_input).cpu().item() for i in range(sample_nbr)]

        test_deque.append(torch.tensor(pred).mean().cpu().item())
        preds_test.append(pred)

        if i % future_length == 0:
            # our inptus become the i index of our X_test
            # That tweak just helps us with shape issues
            test_begin = X_test[i:i + 1, :, :]
            test_deque = deque(test_begin[0, :, 0].tolist(), maxlen=window_size)

    return idx_pred, preds_test


def get_confidence_intervals(preds_test, ci_multiplier, scaler):

    preds_test = torch.tensor(preds_test)

    pred_mean = preds_test.mean(1)
    pred_std = preds_test.std(1).detach().cpu().numpy()

    pred_std = torch.tensor((pred_std))
    # print(pred_std)

    upper_bound = pred_mean + (pred_std * ci_multiplier)
    lower_bound = pred_mean - (pred_std * ci_multiplier)
    # gather unscaled confidence intervals

    pred_mean_final = pred_mean.unsqueeze(1).detach().cpu().numpy()
    pred_mean_unscaled = scaler.inverse_transform(pred_mean_final)

    upper_bound_unscaled = upper_bound.unsqueeze(1).detach().cpu().numpy()
    upper_bound_unscaled = scaler.inverse_transform(upper_bound_unscaled)

    lower_bound_unscaled = lower_bound.unsqueeze(1).detach().cpu().numpy()
    lower_bound_unscaled = scaler.inverse_transform(lower_bound_unscaled)

    return pred_mean_unscaled, upper_bound_unscaled, lower_bound_unscaled


def simulate(X_test, X_train, Xs, scaler, net):
    future_length=7
    sample_nbr=4
    ci_multiplier = 2
    idx_pred, preds_test = prediction(X_test, X_train, Xs, scaler, future_length, net, sample_nbr)
    pred_mean_unscaled, upper_bound_unscaled, lower_bound_unscaled = \
        get_confidence_intervals(preds_test, ci_multiplier, scaler)
    return idx_pred, pred_mean_unscaled, upper_bound_unscaled, lower_bound_unscaled


def bayesian_lstm_processing(task, system_state):
    scaler, dataloader_train, X_train, X_test, y_train, y_test, Xs, ys = pre_processing(system_state)

    if task == 'train':
        net = NN()
        train_lstm(system_state, net, X_train, X_test, y_test, dataloader_train)
    elif task == 'simulate':
        net = torch.load('parameters\lstm_param_' + system_state)
        idx_pred, pred_mean_unscaled, upper_bound_unscaled, lower_bound_unscaled = \
            simulate(X_test, X_train, Xs, scaler, net)
        # plot_lstm(idx_pred, pred_mean_unscaled, upper_bound_unscaled, lower_bound_unscaled)
        return idx_pred, pred_mean_unscaled, upper_bound_unscaled, lower_bound_unscaled
    else:
        raise Exception('The task should be train or simulate')


# Simulation:
# idx_pred, pred_mean_unscaled, upper_bound_unscaled, lower_bound_unscaled = \
#     bayesian_lstm_processing(task='simulate', system_state='station_ko')

# Training:
# for i in ['station_ok', 'station_ko_filter', 'station_ko_valve']:
#     bayesian_lstm_processing(task='train', system_state=i)
