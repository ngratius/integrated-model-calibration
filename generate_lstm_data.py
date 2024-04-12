import numpy as np
import matplotlib.pyplot as plt


def gen_synthetic_data(prediction_horizon, start, end, filename):
    # White Gaussian noise:
    std = 0.01
    noise = np.random.normal(0, std, prediction_horizon)

    # Sigmoid parameters (L: Asymptotic value, k: growth rate, x_0: abscissa of mid-point, s: starting value)
    L = end
    k = np.abs(end-start)*10/prediction_horizon
    x_0 = prediction_horizon/2
    s = start

    # Coordinates of generated points
    x = range(0, prediction_horizon)
    y = [((L-s) / (1 + np.exp(-k * (i - x_0)))) + s for i in x]
    y_noisy = [((L-s) / (1 + np.exp(-k * (i - x_0)))) + s + noise[i] for i in x]

    # Plot
    plt.plot(x, y_noisy, label='Observable data for training')
    plt.plot(x, y, label='Latent ground truth')
    plt.title("Synthetic data: " + filename)
    plt.xlabel("Time [s]")
    plt.ylabel('%')
    plt.axis([0, len(x), 0.4, 1])
    plt.legend()

    # Save to cvs and jpg files
    plt.savefig('data/plot/'+filename+'.png')
    np.savetxt('data/'+filename+'.csv', np.array(y_noisy), delimiter=',', header='data', comments='')

    plt.show()


# Habitat data
gen_synthetic_data(prediction_horizon=3020, start=0.95, end=0.9, filename='habitat_ok')
gen_synthetic_data(prediction_horizon=3020, start=0.95, end=0.6, filename='habitat_ko')

# Vehicle data
gen_synthetic_data(prediction_horizon=3020, start=0.95, end=0.9, filename='vehicle_ok')
gen_synthetic_data(prediction_horizon=3020, start=0.95, end=0.6, filename='vehicle_ko')