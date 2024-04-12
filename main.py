from bayesian_lstm import *
from linear_combination import *
from plot_simulation import *
from pgm_calibration import *
from simulink import *


def calibrate(evidence):
    # Create pgm_model
    pgm_model = create_pgm(plot_pgm=False)

    # Infer system states
    state_v, state_d = infer_param(pgm_model, evidence)

    state_v = 'vehicle_' + state_v
    state_d = 'docked_' + state_d
    state_s = 'station_' + evidence['s']

    return state_s, state_v, state_d


def simulate(state_s, state_v, state_d):
    # Simulate CO2 removal capacities of the station
    idx_pred, s, s_up, s_low = bayesian_lstm_processing(task='simulate', system_state=state_s)

    # Simulate CO2 removal capacities of the vehicle
    dict_simulink = {'vehicle_ko_filter': {"Stop_Time": 118, "Check_valve_severity": 45, "mesh_size": 60},
                     'vehicle_ko_valve': {"Stop_Time": 118, "Check_valve_severity": 3e-7, "mesh_size": 2},
                     'vehicle_ok': {"Stop_Time": 118, "Check_valve_severity": 3e-7, "mesh_size": 60}}
    params = dict_simulink[state_v]
    # params = {"Stop_Time": 118, "Check_valve_severity": 3e-7, "mesh_size": 60}
    v = run_simulink(params, compute=False)
    v_up = v + 0.02
    v_low = v - 0.02

    # Simulate CO2 concentration in docked configuration
    idx_pred, d, d_up, d_low, flight_rule = linear_combination_processing(idx_pred, s, s_up, s_low, v, v_up, v_low,
                                                             task='simulate', system_state=state_d)
    return idx_pred, s, s_up, s_low, v, v_up, v_low, d, d_up, d_low, flight_rule


# 0. Get diagnosis results

intervention = True

if intervention is False:
    evidence = {'s': 'ko_filter'}  # Default diagnosis result
elif intervention is True:
    evidence = {'s': 'ok'}


# 1. Calibration
state_s, state_v, state_d = calibrate(evidence)
print(state_s, state_v, state_d)

# 2. Simulations
idx_pred, s, s_up, s_low, v, v_up, v_low, d, d_up, d_low, flight_rule = simulate(state_s, state_v, state_d)

# 3. Plot
plot(idx_pred, s, s_up, s_low, v, v_up, v_low, d, d_up, d_low, flight_rule)
