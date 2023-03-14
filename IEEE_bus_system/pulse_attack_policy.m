function attack_data = pulse_attack_policy(policy_param,Z_attack_data)
%% function attack_data = pulse_attack_policy(policy_param,Z_attack_data)
% sin attack policy
% y = a*sin(b*t) *(t_start_time<t<t_end_time)
% inputs:
%        policy_param: {attack_start_time_interval, attack_time_span_max_rate, a_attack_interval,b_attack_interval, t_time_stop}
%                     - attack_start_time_interval: [1-by-2] start time interval
%                     - attack_time_span_max_rate: [scalar] attack_time_span_max = attack_time_span_max_rate*t_time_stop
%                     - a_attack_interval: [1-by-2] smallest and biggest value for a
%                     - b_attack_interval: [1-by-2] smallest and biggest value for b
%                     - t_time_stop: [scalar] total simualtion time of system
%        Z_attack_data: [4*n_attacked_nodes,n_sim_samples] attack parameters (percenatages) for each attack node
%              Z_attack_data(1:n_attacked_nodes,:)                     : attack start time for each attack node
%              Z_attack_data(n_attacked_nodes+1:2*n_attacked_nodes,:)  : attack time spans for each attack node
%              Z_attack_data(2*n_attacked_nodes+1:3*n_attacked_nodes,:): a value for each attack node
%              Z_attack_data(3*n_attacked_nodes+1:4*n_attacked_nodes,:): b value for each attack node
% output:
%        attack_data
%
% Author: 
% Yu Zheng, Florida state university
% 03/11/2023

%% attack policy parameters
attack_start_time_interval = policy_param{1,1};
% attack_start_time_interval       = round([0.1 0.2]*t_sim_stop);
delta_attack_start_time_interval = attack_start_time_interval(2) - attack_start_time_interval(1);
% attack_time_span_max = round(0.3*t_sim_stop);
attack_time_span_max_rate = policy_param{1,2};
t_sim_stop = policy_param{1,5};
attack_time_span_max = attack_time_span_max_rate*t_sim_stop;
% attack_max = 50;
a_attack_interval = policy_param{1,3};
b_attack_interval = policy_param{1,4};
n_attacked_nodes = round(size(Z_attack_data,1)/4);

%% generate attacks
% attack start times
attack_start_times = attack_start_time_interval(1) + ...
    delta_attack_start_time_interval*Z_attack_data(1:n_attacked_nodes,:);

% attack time spans
attack_time_span_min = 2e-5;
attack_time_span   = attack_time_span_min + attack_time_span_max*Z_attack_data(n_attacked_nodes+1:2*n_attacked_nodes,:);

% attack final deviations
a_attack = a_attack_interval(1)+(a_attack_interval(2)-a_attack_interval(1))*Z_attack_data(2*n_attacked_nodes+1:3*n_attacked_nodes,:);
b_attack = b_attack_interval(1)+(b_attack_interval(2)-b_attack_interval(1))*Z_attack_data(3*n_attacked_nodes+1:4*n_attacked_nodes,:);
attack_deviation_param = [a_attack; b_attack];

attack_data = [attack_start_times;
               attack_time_span;
               attack_deviation_param];
