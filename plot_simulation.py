import matplotlib
import matplotlib.pyplot as plt
import numpy as np


def plot(idx_pred, h, h_up, h_low, v, v_up, v_low, d, d_up, d_low, flight_rule):

    x = idx_pred - np.min(idx_pred)

    # plt.rcParams['font.size'] = 8

    plt.rcParams['font.size'] = 10

    fig = plt.figure()
    ax1 = fig.add_subplot(221)
    ax2 = fig.add_subplot(222)
    ax3 = fig.add_subplot(212)

    # fig.suptitle('State: Valve stiction, Intervention: None', fontweight='bold')

    ax1.plot(x, v)
    ax2.plot(x, h)
    ax3.plot(x, d)

    # ax3.fill_between(x=x, y1=0, y2=0.8, facecolor='bisque', label='Danger zone')

    ax1.fill_between(x=x, y1=v_up[:, 0], y2=v_low[:, 0], facecolor='silver', label="95% CI")
    ax2.fill_between(x=x, y1=h_up[:, 0], y2=h_low[:, 0], facecolor='silver', label="95% CI")
    ax3.fill_between(x=x, y1=d_up[:, 0], y2=d_low[:, 0], facecolor='silver', label="95% CI")

    ax1.set_title('Vehicle \n CO2 removal capacity')
    ax2.set_title('Station \n CO2 removal capacity')
    ax3.set_title('CO2 in habitat after docking')

    ax1.set(xlabel='Time [min]', ylabel="$1 - CO2_{out}/CO2_{in}$ [%]")
    ax2.set(xlabel='Time [min]', ylabel="$1 - CO2_{out}/CO2_{in}$ [%]")
    ax3.set(xlabel='Time [min]', ylabel='CO2 concentration [ppm]')

    ax3.text(0.5, -0.5, 'FLIGHT RULE:\n' + flight_rule,
             horizontalalignment='center', verticalalignment='center', transform=ax3.transAxes,
             bbox=dict(boxstyle='round', facecolor='#1f77b4', alpha=0.2), wrap=True)

    ax1.legend()
    ax2.legend()
    ax3.legend()

    plt.tight_layout()

    plt.savefig('simulation_results.png')
    plt.show()

