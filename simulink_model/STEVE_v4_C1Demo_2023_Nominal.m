%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set Simulation Conditions %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Nominal Ops
    num_cycle=9; %Total unmber of cycles. NOTE:You must manually adjust the simulation time in the Simulink GUI
    flow_rate=8; %MFC flow rate[lpm]
    room_temp=21+273;  %room temperature [K]
    room_pressure =13.3; %psi - Default 13.3 (Boulder Pressure)
    CO2_concentration=0.00042; %Mole Fraction. Crewed 0.003 Uncrewed 0.00042

% Anomalies (only for valve stiction)
    Leak=0; % No leak(0) / Leak(1)
    Leak_timing = 4; %At what cycle will the leak be introduced?
    Leak_severity =4.8e-10; %What is the severity of the leak (i.e., leak valve local restriction area [in2])

    Check_valve=0; % No Check valve anomaly(0) / Check valve anomaly(1)
    Check_valve_timing=1;  %At what cycle will the check valve anomaly be introduced?
    Check_valve_severity =3e-7; %What is the severity of the check valve anomaly (i.e., belimo valve position [deg]). Originally 3e-7
    
    Vacuum=0; % No Check valve anomaly(0) / Check valve anomaly(1)
    Vacuum_timing=4; %At what cycle will the vacuum anomaly be introduced?
    Vacuum_severity=1156; %Originally 606. What is the severity of the vacuum anomaly (i.e., Vacuum pump performance curve equation offset value) [Pa]

%%%%%%%%%%%%%%%%%%%%%
% Piping Parameters %
%%%%%%%%%%%%%%%%%%%%%

    pipe_HD=0.43; %pipe hydrawlic diameter [in]
    Pipe_ave_HD=(pipe_HD+0.5)/2;
    pipe_wall=0.035; %pipe wall thickness [in]
    pipe_tc=14.4; %pipe thermal conductivity [W/(m*k)]
    Bed_thickness=0.049;
    %roughness = 1e-6; % Absolute roughness of bead blasted stainless steel[m]
    roughness=15e-6;

%%%%%%%%%%%%%%%%%%%%%
% Filter Parameters %
%%%%%%%%%%%%%%%%%%%%%    
    
    mesh_size=15; %μm

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sorbent bed parameters %
%%%%%%%%%%%%%%%%%%%%%%%%%%

%1-d adsorption model parameters
    L = 0.508; %Bed length [m]
    z = 0:0.05:L;                % Spatial mesh generation
    n = numel(z);                % Size of mesh grid
    Heat_ads=40000; % Heat of adsorption [J/mol]

% Heater Parameters 
    Heater_output = 85.3; %J/s Heater resistance 75(Ohm), Voltage 80(V)
    Ramp_rate=0.0833; %degC/s (same as K/s) Dafault: 5 degC/min 0.0833 
    Ins_tc= 0.01; %Insulation level in thermal conductivity
    max_temp=200+273.15; %[K] Max temp of the sorbent bed during nominal desorption

%Other bed parameters
    L_inch=L*39.3701; %Bed length in inches
    Bed_ins_OD=2.334; % Bed OD with insulation [in]
    Bed_ave_OD=(1+Bed_ins_OD)/2; %Bed average OD with insulation [in]. (1 in pipe only OD + 2.334 Bed OD with insulation)/2

%%%%%%%%%%%%%%%%%%%%
% Valve Parameters %
%%%%%%%%%%%%%%%%%%%%

    Belimo_Cv=16; 
    Valve_pos_int=89.9999; %deg. 90 - Open, 0- Close
    Valve_rot_st_t=2000; %s. Time to start valve rotation
    Valve_rot_dur_t=5;%s Speed for valve to rotate
    Valve_pos_fin=89.9999;%deg. 90 - Open, 0- Close

%%%%%%%%%%%%%%%%%%%%%%%%% 
% Cyclic Ops Parameters %
%%%%%%%%%%%%%%%%%%%%%%%%%

% Time
    Adsorption_time=4800; %[s]
    %Adsorption_time=100; %[s]
    FlowStop_time=5;%[s] Do not recommend changing
    Valve_close_Time=5; %[s]
    Select_valve_close_Time=5;%[s] Do not recommend changing
    Pump_down_time=10; %[s]
    Desorption_time=4800; %[s]
    %Desorption_time=200; %[s]
    SelectValve_open_Time=5;%[s] Do not recommend changing
    Valve_open_Time=5;%[s] 
    t_Total=Adsorption_time + FlowStop_time + Valve_close_Time + Select_valve_close_Time + Pump_down_time + Desorption_time + SelectValve_open_Time + Valve_open_Time;
    %Stop_Time=t_Total*num_cycle;% Simulation run time[s]
    Stop_Time=100
    Timing=[Adsorption_time FlowStop_time Valve_close_Time Select_valve_close_Time Pump_down_time Desorption_time SelectValve_open_Time Valve_open_Time];
    Ads_tot= Adsorption_time + FlowStop_time + Valve_close_Time + Select_valve_close_Time;
% Vacuum Pump ON/OFF
    Pump_on_off_st= [1e-10 1e-10 1e-10 1e-10 1e-10 (pi*(0.43-1e-10)^2)/4 1e-10 1e-10];
    Pump_on_off_end=[1e-10 1e-10 1e-10 1e-10 (pi*(0.43-1e-10)^2)/4 (pi*(0.43-1e-10)^2)/4 1e-10 1e-10];
    signal_st= [0 0 0 0 1 1 0 0];
    signal_end=[0 0 0 0 1 1 0 0];
    P_vac_st=   [94600 94600 94600 94600 94600 2600 94600 94600];
    P_vac_end=  [94600 94600 94600 94600 2600 2600 94600 94600];

%Heater signal
    htr_signal_st= [0 0 0 0 1 1 0 0];
    htr_signal_end=[0 0 0 0 1 1 0 0];

%Selector valve open(flow)/close(vac)
    Select_valve_st=    [(pi*(0.43-1e-10)^2)/4 (pi*(0.43-1e-10)^2)/4 (pi*(0.43-1e-10)^2)/4 (pi*(0.43-1e-10)^2)/4 1e-10 1e-10 1e-10 (pi*(0.43-1e-10)^2)/4];
    Select_valve_end=   [(pi*(0.43-1e-10)^2)/4 (pi*(0.43-1e-10)^2)/4 (pi*(0.43-1e-10)^2)/4 1e-10 1e-10 1e-10  (pi*(0.43-1e-10)^2)/4 (pi*(0.43-1e-10)^2)/4];

%Check valve (Belimo valve) Ops
    Valve_op_cl_st= [89.9999 89.9999 89.9999 0 0 0 0 0];  %Belimo valve open/close
    Valve_op_cl_end=[89.9999 89.9999 0 0 0 0 0 89.9999];  %Belimo valve open/close
    %valve_cont_sig=[0 0 0 0 0 0 1 1]; %Other
    valve_cont_sig=[0 0 0 0 0 0 1 1]; %Other
    belimo_sig=[0 0 0 0 0 0 0 1]; %Other
    cycle_end_sig=[1 1 1 1 1 1 1 0]; %Other

%Flow rate
    FR_st=  [flow_rate*0.001/60 flow_rate*0.001/60 0 0 0 0 0 0];
    FR_end= [flow_rate*0.001/60 0 0 0 0 0 0 0];

%CO2 on/off
    CO2_st=[1 1 0 0 0 0 0 0];
    CO2_end=[1 1 0 0 0 0 0 0];

%Adsorption/Desorption signal
    Des_st=[1 1 1 1 1 0 1 1];
    Des_end=[1 1 1 1 1 0 1 1];
    Ads_st=[0 1 1 1 1 1 1 1];
    Ads_end=[0 1 1 1 1 1 1 1];

% %Pump Flow signal
% Pump_flow_st=[1 1 1 1 1 1 0 0];
% Pump_flow_end=[1 1 1 1 1 1 0 0];

%%%%%%%%%%%%%%%%%%%%%%
% Anomaly Parameters %
%%%%%%%%%%%%%%%%%%%%%%

    Anomaly_timing = repmat(t_Total,1,num_cycle);

%Leak valve 
    if Leak ==0
        Leak_valve_deg_st=repmat(1e-10,1,num_cycle); % Leak valve closed
        Leak_valve_deg_end=repmat(1e-10,1,num_cycle); % Leak valve closed
    else
        Leak_nom=repmat(1e-10,1,Leak_timing-1);
        Leak_anom=repmat(Leak_severity,1,num_cycle-Leak_timing+1);
        Leak_valve_deg_st=[Leak_nom Leak_anom];
        Leak_valve_deg_end=[Leak_nom Leak_anom];
    end

%Vacuum pressure anomaly
    if Vacuum ==0
        vac_anom_st=repmat(547,1,num_cycle); % Nominal vacuum. Originally 197. Now 547
        vac_anom_end=repmat(547,1,num_cycle); % Nominal vacuum. Originally 197.
    else
        Vac_nom=repmat(547,1,Vacuum_timing-1);%Originally 197.
        Vac_anom=repmat(Vacuum_severity,1,num_cycle-Vacuum_timing+1);
        vac_anom_st=[Vac_nom Vac_anom]; % Nominal vacuum
        vac_anom_end=[Vac_nom Vac_anom]; % Nominal vacuum
    end

% Check valve anomaly
    if Check_valve ==0
        valve_anom_signal_st=zeros(1,num_cycle); % Nominal vacuum
        valve_anom_signal_end=zeros(1,num_cycle); % Nominal vacuum
    else
        Valve_nom=zeros(1,Check_valve_timing-1);
        Valve_anom=ones(1,num_cycle-Check_valve_timing+1);
        valve_anom_signal_st=[Valve_nom Valve_anom]; % Nominal vacuum
        valve_anom_signal_end=[Valve_nom Valve_anom]; % Nominal vacuum
    end

    Bad_Valve_op_cl_st= [89.9999 89.9999 89.9999 Check_valve_severity Check_valve_severity Check_valve_severity Check_valve_severity Check_valve_severity];
    Bad_Valve_op_cl_end=[89.9999 89.9999 Check_valve_severity Check_valve_severity Check_valve_severity Check_valve_severity Check_valve_severity 89.9999];


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    load_system('STEVE_ver28.slx');
    simIn=Simulink.SimulationInput('STEVE_ver28');
    simOut=sim(simIn);
    
    SensorAI16=simOut.ScopeDataPressure.signals.values(:,1);
    SensorAI32=simOut.ScopeBedPressure.signals.values(:);
    SensorAI2=simOut.ScopeDataCO2.signals.values(:,2);
    SensorAI10=simOut.ScopeDataCO2.signals.values(:,2);

    bdclose('STEVE_ver28.slx')
%% Create Data File (Table) with noise

% Data=[];
% Data.Time_sec_=ScopeBedPressure.time;
% Data.AI0_UpstreamLowFM_SLPM_=ScopeDataFlowRate.signals.values(:,1);
% Data.AI1_DownstreamLowFM_SLPM_=ScopeDataFlowRate.signals.values(:,2);
% Data.AI4_DownstreamO2___=ScopeDataO2.signals.values(:,2);
% Data.AI5_UpstreamTemperature_C_=ScopeDataTemp.signals.values(:,1);
% Data.AI6_DownstreamTemperature_C_=ScopeDataTemp.signals.values(:,1);
% Data.AI11_UpstreamO2___=ScopeDataO2.signals.values(:,1);
% Data.AI16_UpstreamAbsPressure_kPa_=ScopeDataPressure.signals.values(:,1);
% Data.AI22_SorbentBedDP_psi_=ScopeDataDeltaP.signals.values(:,1);
% Data.AI23_FilterDP_psi_=ScopeDataDeltaP.signals.values(:,2);
% Data.AI24_DownstreamAbsPressure_kPa_=ScopeDataPressure.signals.values(:,1);
% Data.AI32_BedInletPress_psi_=ScopeBedPressure.signals.values(:);
% Data.TC1T1=ScopeDataBedTemp.signals.values(:,4);
% Data.TC1T2=ScopeDataBedTemp.signals.values(:,1);
% Data.TC1T3=ScopeDataBedTemp.signals.values(:,2);
% Data.TC1T4=ScopeDataBedTemp.signals.values(:,3);
% Data.TC2T5=ScopeDataBedTemp.signals.values(:,5);
% Data.AI2_DownstreamCO2___=ScopeDataCO2.signals.values(:,2);
% Data.AI10_UpstreamCO2___=ScopeDataCO2.signals.values(:,2);
% Data.UpstreamDewpoint_C_=ScopeDataDewPoint.signals.values(:,1);
% Data.DownstreamDewpoint_C_=ScopeDataDewPoint.signals.values(:,2);
% Data.numberOfCycles=ScopeDataCycle.signals.values;
% Data.nXDSOff_On=ScopeDataDesSig.signals.values;
% Data.HeaterSig=ScopeDataHeaterSig.signals.values;
% Data.AI20_FastValveOutput_deg_=ScopeDataValvePos.signals.values(:);
% 
% Data=struct2table(Data);
% writetable(Data,'Nominal.csv')
% 
% %% Create Data File (Table) without noise
% 
% CleanData=[];
% CleanData.Time_sec_=ScopeBedPressureClean.time;
% CleanData.AI0_UpstreamLowFM_SLPM_=ScopeDataFlowRateClean.signals.values(:,1);
% CleanData.AI1_DownstreamLowFM_SLPM_=ScopeDataFlowRateClean.signals.values(:,2);
% CleanData.AI4_DownstreamO2___=ScopeDataO2Clean.signals.values(:,2);
% CleanData.AI5_UpstreamTemperature_C_=ScopeDataTempClean.signals.values(:,1);
% CleanData.AI6_DownstreamTemperature_C_=ScopeDataTempClean.signals.values(:,1);
% CleanData.AI11_UpstreamO2___=ScopeDataO2Clean.signals.values(:,1);
% CleanData.AI16_UpstreamAbsPressure_kPa_=ScopeDataPressureClean.signals.values(:,1);
% CleanData.AI22_SorbentBedDP_psi_=ScopeDataDeltaPClean.signals.values(:,1);
% CleanData.AI23_FilterDP_psi_=ScopeDataDeltaPClean.signals.values(:,2);
% CleanData.AI24_DownstreamAbsPressure_kPa_=ScopeDataPressureClean.signals.values(:,1);
% CleanData.AI32_BedInletPress_psi_=ScopeBedPressureClean.signals.values(:);
% CleanData.TC1T1=ScopeDataBedTempClean.signals.values(:,4);
% CleanData.TC1T2=ScopeDataBedTempClean.signals.values(:,1);
% CleanData.TC1T3=ScopeDataBedTempClean.signals.values(:,2);
% CleanData.TC1T4=ScopeDataBedTempClean.signals.values(:,3);
% CleanData.TC2T5=ScopeDataBedTempClean.signals.values(:,5);
% CleanData.AI2_DownstreamCO2___=ScopeDataCO2Clean.signals.values(:,2);
% CleanData.AI10_UpstreamCO2___=ScopeDataCO2Clean.signals.values(:,2);
% CleanData.UpstreamDewpoint_C_=ScopeDataDewPointClean.signals.values(:,1);
% CleanData.DownstreamDewpoint_C_=ScopeDataDewPointClean.signals.values(:,2);
% CleanData.numberOfCycles=ScopeDataCycle.signals.values;
% CleanData.nXDSOff_On=ScopeDataDesSig.signals.values;
% CleanData.HeaterSig=ScopeDataHeaterSig.signals.values;
% CleanData.AI20_FastValveOutput_deg_=ScopeDataValvePosClean.signals.values;
% 
% CleanData=struct2table(CleanData);
% writetable(CleanData,'ValveAnom_clean.csv')

