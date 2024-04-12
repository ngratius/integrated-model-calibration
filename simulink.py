import matlab.engine
import numpy as np
import pickle
import matplotlib.pyplot as plt


def run_simulink(params, compute):
    if compute is False:
        # load outputs from file:
        with open('simulink_model/simulink_recorded_outputs/'+
                  'outputs_duration-'+str(params["Stop_Time"])+
                  '_valve-'+str(params["Check_valve_severity"])+
                  '_filter-'+str(params["mesh_size"])+'.pkl', 'rb') as f:
            co2_removed = pickle.load(f)
        return co2_removed
    else:
        # Sensors to be returned:
        # SensorAI2: co2 outlet / SensorAI10: co2 inlet
        output_labels = ["SensorAI2", "SensorAI10"]

        # initialization
        eng = matlab.engine.start_matlab()
        eng.cd('./simulink_model')
        eng.STEVE_initialization(nargout=0)
        print('Simulink initialization complete')

        # calibration (assign params values)
        for key, value in params.items():
            eng.workspace[key] = float(value)
        print('Simulink calibration complete')

        # inference (run simulink model)
        print('Simulink inference ongoing ...')
        eng.STEVE_running(nargout=0)
        print('Simulink inference complete')

        # reformat simulink output to python object
        outputs = {}
        for sensor in output_labels:
            ts = eng.eval(sensor)
            print(f'ts: {ts}')
            outputs[sensor] = np.array(ts).ravel().tolist()

        eng.quit()

        co2_outlet = np.array(outputs["SensorAI2"])
        co2_inlet = np.array(outputs["SensorAI10"])

        co2_removed = (co2_inlet - co2_outlet) / co2_inlet

        # remove the 10 first entries of co2_removed:
        co2_removed = co2_removed[10:].reshape(-1, 1)

        # save outputs to file:
        with open('simulink_model/simulink_recorded_outputs/'
                  + 'outputs' + '_duration-' + str(params["Stop_Time"])
                  + '_valve-' + str(params["Check_valve_severity"])
                  + '_filter-' + str(params["mesh_size"]) + '.pkl', 'wb') as f:
            pickle.dump(co2_removed, f)

        return co2_removed


# nominal params : {"Check_valve_severity": 3e-7, "mesh_size": 60}
# params = {"Stop_Time": 122, "Check_valve_severity": 45, "mesh_size": 60}
#
# co2_removed = run_simulink(params, compute=True)

# plot co2 removed:
# x = np.arange(0, params["Stop_Time"] - 10 + 1)
# y1 = co2_removed
# fig, ax = plt.subplots(1, 1, sharex=True)
# ax.plot(x, y1)
# ax.set_title("CO2 removed (%)")
# plt.show()
