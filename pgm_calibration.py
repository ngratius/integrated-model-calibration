from pgmpy.models import BayesianNetwork
from pgmpy.factors.discrete import TabularCPD
from pgmpy.inference import VariableElimination
import networkx as nx
import matplotlib.pyplot as plt


def create_pgm(plot_pgm):
    # Define edges
    pgm_model = BayesianNetwork([('s', 'v'), ('s', 'd'), ('v', 'd')])

    # Define parameters
    p1, p2 = 0.5, 0.2
    p3, p4, p5, p6, p7, p8 = 0.4, 0.6, 0.75, 0.5, 0.4, 0.6
    p9, p10, p11, p12, p13, p14, p15, p16, p17 = 0.4, 0.6, 0.75, 0.5, 0.4, 0.6, 0.6, 0.4, 0.1

    # Define CPDs (columns are evidences and rows are variable states)
    cpd_station = TabularCPD(variable='s', variable_card=3,
                             values=[[p1], [p2], [1-p1-p2]],
                             state_names={'s': ['ko_filter', 'ko_valve', 'ok']})

    cpd_vehicle = TabularCPD(variable='v', variable_card=3,
                             values=[[p3, p5, p7],
                                     [p4, p6, p8],
                                     [1-p3-p4, 1-p5-p6, 1-p7-p8]],
                             evidence=['s'], evidence_card=[3],
                             state_names={'v': ['ko_filter', 'ko_valve', 'ok'],
                                          's': ['ko_filter', 'ko_valve', 'ok']})

    cpd_docked = TabularCPD(variable='d', variable_card=2,
                            values=[[p9, p10, p11, p12, p13, p14, p15, p16, p17],
                                    [1-p9, 1-p10, 1-p11, 1-p12, 1-p13, 1-p14, 1-p15, 1-p16, 1-p17]],
                            evidence=['v', 's'], evidence_card=[3, 3],
                            state_names={'d': ['ko', 'ok'],
                                         'v': ['ko_filter', 'ko_valve', 'ok'],
                                         's': ['ko_filter', 'ko_valve', 'ok']})

    # Associate CPDs with the network
    pgm_model.add_cpds(cpd_station, cpd_vehicle, cpd_docked)

    # Check model structure and param. sum to 1
    pgm_model.check_model()

    if plot_pgm is True:
        # Print CPDs
        # print('P(station):')
        # print(cpd_station)
        # print()
        # print('P(vehicle|station):')
        # print(cpd_vehicle)
        # print()
        # print('P(docked|station,vehicle):')
        # print(cpd_docked)

        # Plot network

        pos = nx.spring_layout(pgm_model, seed=42)
        nx.draw(pgm_model, pos, with_labels=True, font_color="whitesmoke", node_color='royalblue', node_size=1000)

        s_x, s_y = pos['s']
        plt.text(s_x - 0.25, s_y - 0.2, s=cpd_station,
                 bbox=dict(facecolor='royalblue', alpha=0.4), horizontalalignment='center')

        v_x, v_y = pos['v']
        plt.text(v_x - 0.1, v_y + 0.2,
                 s=cpd_vehicle, bbox=dict(facecolor='royalblue', alpha=0.4), horizontalalignment='center')

        d_x, d_y = pos['d']
        plt.text(d_x + 0.4, d_y + 0.3,
                 s=cpd_docked, bbox=dict(facecolor='royalblue', alpha=0.4), horizontalalignment='center')

        # plt.suptitle('PGM encoding system state dependencies')
        plt.suptitle('s:station - v:vehicle - d:docked')
        plt.show()
    return pgm_model


def infer_param(pgm_model, evidence):
    infer = VariableElimination(pgm_model)
    state_d = infer.map_query(['v', 'd'], evidence)['d']
    state_v = infer.map_query(['v', 'd'], evidence)['v']
    return state_v, state_d

