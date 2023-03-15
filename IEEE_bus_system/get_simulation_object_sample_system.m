function [sim_out] = get_simulation_object_sample_system(sim_inp_in,attack_data,attack_percentage, attack_type)
% Returns an array of Simulink.SimulationInput object for parrallel
% execution
%
%       This function is specific to the sample_system used to develop the code.
%       Use this as a template to create get_simulation_objec_*** for the
%       relevant system later.
%
%
% Input:
% - batch_size [Integer]: The size of object to return

% Yu Zheng 2/11/2023


%% Parameters
batch_size = size(attack_data,2);

%% load system parameters 
%*******************************************
% REPLACE WITH CALL TO RELEVANT RUNFILE
%*******************************************
Run_sim  


%% Simulation objects

% NOTE: All variables will be supplied by a call to the run file 
%                     (Run_Sim in this case)
if(isempty(sim_inp_in))

    model = 'bus_system';
    load_system(model);

%     % build rapid accelerator target
%     Simulink.BlockDiagram.buildRapidAcceleratorTarget(model);

    % simulation input objects'
    sim_inp = repmat(Simulink.SimulationInput(model),batch_size,1);
    for iter = 1:batch_size

%         sim_inp(iter) = sim_inp(iter).setModelParameter('SimulationMode','rapid-accelerator');
%         sim_inp(iter) = sim_inp(iter).setModelParameter('RapidAcceleratorUpToDateCheck','off');

% system param
        sim_inp(iter) = sim_inp(iter).setVariable('n_gen',n_gen);
        sim_inp(iter) = sim_inp(iter).setVariable('n_bus',n_bus);
        sim_inp(iter) = sim_inp(iter).setVariable('n_states',n_states);
        sim_inp(iter) = sim_inp(iter).setVariable('n_meas',n_meas);
        sim_inp(iter) = sim_inp(iter).setVariable('load_buses',load_buses);
        sim_inp(iter) = sim_inp(iter).setVariable('A_bar_d',A_bar_d);
        sim_inp(iter) = sim_inp(iter).setVariable('B_bar_d',B_bar_d);
        sim_inp(iter) = sim_inp(iter).setVariable('C_obsv_d',C_obsv_d);
        sim_inp(iter) = sim_inp(iter).setVariable('D_obsv_d',D_obsv_d);
        sim_inp(iter) = sim_inp(iter).setVariable('L_obsv',L_obsv);
% sim param
        sim_inp(iter) = sim_inp(iter).setVariable('x0',x0);
        sim_inp(iter) = sim_inp(iter).setVariable('x0_hat',x0_hat);
        sim_inp(iter) = sim_inp(iter).setVariable('T_sample',T_sample);
        sim_inp(iter) = sim_inp(iter).setVariable('T_final',T_final);
        sim_inp(iter) = sim_inp(iter).setVariable('U2',U2);

    end
else
    sim_inp = sim_in_in;
end

%% Run simulation in parralel 
for iter = 1:batch_size
    if attack_type == "ramp"
        % for ramp, pulse attack
        attack_start_times      = attack_start_injection*ones(n_meas,1);
        attack_full_times       = attack_start_times +  0;
        attack_final_deviations = zeros(n_meas,1);
    
        attack_start_times(attack_indices)      = attack_data(1:n_attacked_nodes,iter);
        attack_full_times(attack_indices)       = attack_start_times(attack_indices) + attack_data(n_attacked_nodes+1:2*n_attacked_nodes,iter);
        attack_final_deviations(attack_indices,1) = attack_data(2*n_attacked_nodes+1:3*n_attacked_nodes,iter);
        attack_final_deviations(attack_indices,2) = attack_data(3*n_attacked_nodes+1:4*n_attacked_nodes,iter);
    
        sim_inp(iter) = sim_inp(iter).setVariable('attack_start_times',attack_start_times);
        sim_inp(iter) = sim_inp(iter).setVariable('attack_full_times',attack_full_times);
        sim_inp(iter) = sim_inp(iter).setVariable('attack_final_deviations',attack_final_deviations);
    elseif attack_type == "sin" || attack_type == "pulse"
        % for sin attack
        attack_start_times      = attack_start_injection*ones(n_meas,1);
        attack_full_times       = attack_start_times + 0;
        attack_final_deviations = zeros(n_meas,2);
    
        attack_start_times(attack_indices)      = attack_data(1:n_attacked_nodes,iter);
        attack_full_times(attack_indices)       = attack_start_times(attack_indices) + attack_data(n_attacked_nodes+1:2*n_attacked_nodes,iter);
        attack_final_deviations(attack_indices,1) = attack_data(2*n_attacked_nodes+1:3*n_attacked_nodes,iter);
        attack_final_deviations(attack_indices,2) = attack_data(3*n_attacked_nodes+1:4*n_attacked_nodes,iter);
    
        sim_inp(iter) = sim_inp(iter).setVariable('attack_start_times',attack_start_times);
        sim_inp(iter) = sim_inp(iter).setVariable('attack_full_times',attack_full_times);
        sim_inp(iter) = sim_inp(iter).setVariable('attack_final_deviations',attack_final_deviations);
    end
end

sim_out = parsim(sim_inp);

%% calculate effectiveness and stealthiness
% [effect_index, stealth_index] = get_error_from_nominal(sim_out,yc_nominal,r_nominal);
