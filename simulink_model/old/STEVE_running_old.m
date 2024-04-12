   Pipe_ave_HD=(pipe_HD+0.5)/2;

    z = 0:0.05:L;                % Spatial mesh generation
    n = numel(z);                % Size of mesh grid


    Bed_ave_OD=(1+Bed_ins_OD)/2; %Bed average OD with insulation [in]. (1 in pipe only OD + 2.334 Bed OD with insulation)/2


    t_Total=Adsorption_time + FlowStop_time + Valve_close_Time + Select_valve_close_Time + Pump_down_time + Desorption_time + SelectValve_open_Time + Valve_open_Time;
    %Stop_Time=t_Total*num_cycle;% Simulation run time[s]
    Timing=[Adsorption_time FlowStop_time Valve_close_Time Select_valve_close_Time Pump_down_time Desorption_time SelectValve_open_Time Valve_open_Time];
    Ads_tot= Adsorption_time + FlowStop_time + Valve_close_Time + Select_valve_close_Time;

    %Flow rate
    FR_st=  [flow_rate*0.001/60 flow_rate*0.001/60 0 0 0 0 0 0];
    FR_end= [flow_rate*0.001/60 0 0 0 0 0 0 0];

    Anomaly_timing = repmat(t_Total,1,num_cycle);

    Timing=[Adsorption_time FlowStop_time Valve_close_Time Select_valve_close_Time Pump_down_time Desorption_time SelectValve_open_Time Valve_open_Time];
    Ads_tot= Adsorption_time + FlowStop_time + Valve_close_Time + Select_valve_close_Time;

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

    Bad_Valve_op_cl_st= [Check_valve_severity Check_valve_severity Check_valve_severity Check_valve_severity Check_valve_severity Check_valve_severity Check_valve_severity Check_valve_severity];
    Bad_Valve_op_cl_end=[Check_valve_severity Check_valve_severity Check_valve_severity Check_valve_severity Check_valve_severity Check_valve_severity Check_valve_severity Check_valve_severity];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    load_system('STEVE_ver28.slx');
    simIn=Simulink.SimulationInput('STEVE_ver28');
    simOut=sim(simIn);
    
    SensorAI16=simOut.ScopeDataPressure.signals.values(:,1);
    SensorAI32=simOut.ScopeBedPressure.signals.values(:);