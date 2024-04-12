import pickle


# param = [station weight, vehicle weight]
import numpy as np


def train_linear():
    lin_param_docked_ok = [1.1, 1] # Activate_backup_unit = False
    lin_param_docked_ko = [1.15, 1.05]  # Activate_backup_unit = True
    with open('parameters/lin_param_docked_ok.pkl', 'wb') as f:
        pickle.dump(lin_param_docked_ok, f)
    with open('parameters/lin_param_docked_ko.pkl', 'wb') as f:
        pickle.dump(lin_param_docked_ko, f)


def linear_combination(s_weight, v_weight, idx_pred, s, s_up, s_low, v, v_up, v_low):
    total_weight = s_weight + v_weight

    d_percent = ((s * s_weight + v * v_weight)/total_weight)
    d_up_percent = ((s_up * s_weight + v_up * v_weight)/total_weight)
    d_low_percent = ((s_low * s_weight + v_low * v_weight)/total_weight)

    # Convert to ppm st. 0.3% is nominal and 0.5% is off-nominal:

    w = -1100
    b = 1380
    d = w * d_percent + b
    d_up = w * d_up_percent + b
    d_low = w * d_low_percent + b

    # Define the correct flight rule

    avg = np.average(d)

    if avg <= 6974:
        flight_rule = 'Proceed with nominal operations'
    elif 6974 < avg <= 1000:
        flight_rule = 'Consult flight surgeon when planning crew activities'
    elif 10000 < avg <= 13158:
        flight_rule = 'Take corrective measure (doc B17-5)'
    elif 13158 < avg <= 19737:
        flight_rule = 'Take corrective measure (doc B17-5), If symptoms: Wear Individual Breathing Device\n' \
                      '(3) If IBD expended or exposure > 13 000 ppm for 8h: Evacuate'
    else:
        flight_rule = '(1) Take corrective measure (see doc B17-5), Wear Individual Breathing Device\n' \
                      '(3) If IBD expended or exposure > 20 000 ppm: Evacuate'

    return idx_pred, d, d_up, d_low, flight_rule


def linear_combination_processing(idx_pred, s, s_up, s_low, v, v_up, v_low, task, system_state):

    if task == 'train':
        train_linear()
    elif task == 'simulate':
        with open('parameters/lin_param_' + system_state + '.pkl', 'rb') as f:
            param = pickle.load(f)
            s_weight, v_weight = param[0], param[1]

        return linear_combination(s_weight, v_weight, idx_pred, s, s_up, s_low, v, v_up, v_low)

    else:
        raise Exception('The task should be train or simulate')





