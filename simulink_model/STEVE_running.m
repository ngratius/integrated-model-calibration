    Pipe_ave_HD=(pipe_HD+0.5)/2;

    z = 0:0.05:L;                % Spatial mesh generation
    n = numel(z);                % Size of mesh grid
    
    Bed_ave_OD=(1+Bed_ins_OD)/2; %Bed average OD with insulation [in]. (1 in pipe only OD + 2.334 Bed OD with insulation)/2

    t_Total=Adsorption_time + FlowStop_time + Valve_close_Time + Select_valve_close_Time + Pump_down_time + Desorption_time + SelectValve_open_Time + Valve_open_Time;

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
    SensorAI10=simOut.ScopeDataCO2.signals.values(:,1);
    SensorAI2=simOut.ScopeDataCO2.signals.values(:,2);

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

