function [test_score_dis,test_score_sim,y_stealth,y_effect,stealth_index, effect_index] = Performance_evaluation(gen_net,stealth_net,effect_net,thresholds,n_test,attack_percentage,policy_param,plot_flag)
%% function test_score = Performance_evaluation(gen_net,stealth_net,effect_net,thresholds)
% two tests:
%           1) run generator, obtain stealth and effect indexes from discriminators
%           2) run generator, obtain stealth and effect indexes from model simualtion
% Inputs: 
%        gen_net          : dl object for generator network
%        stealth_net      : dl object for stealthiness network
%        effect_net       : dl object for effectiveness network
%        thresholds       : [1-by-2] [thresh_1 (threshold for steathiness), thresh_2 (threshold for effectiveness)]
%        n_test           : [scalar] number of test samples
%        t_sim_stop       : [scalar] total simulation time
%        plot_flag        : [false/true] plot flag for test performance
% Outputs:
%        test_score_dis       : [scalar] the ratio of feasible attacks among all samples (with discrimiantors)
%        test_score_sim       : [scalar] the ratio of feasible attacks among all samples (with model simualtion)
%        y_stealth            : [n_test-by-1] stealth index of test samples (with discrimiantors)
%        y_effect             : [n_test-by-1] effect index of test samples (with discrimiantors)
%        stealth_index        : [n_test-by-1] stealth index of test samples (with model simulation)
%        effect_index         : [n_test-by-1] effect index of test samples (with model simulation) 
%
% Author: Yu Zheng, Florida state university
% 08/19/2022

%% Testing performance with repect to the trained discriminators
attack_indices = load("attack_support.mat").attack_indices;
thresh_1 = thresholds(1);
thresh_2 = thresholds(2);

inp_size = gen_net.Layers(1, 1).InputSize;


Z_test        = rand(inp_size,n_test,"single");   % uniformly random noise as input
Z_tet_dlarray = dlarray(Z_test,"CB");                         % covert to dlarray

test_out = double(forward(gen_net,Z_tet_dlarray));

y_stealth = extractdata(forward(stealth_net,test_out));
y_effect  = extractdata(forward(effect_net,test_out));

f1_out = y_stealth - thresh_1;
f2_out = thresh_2 - y_effect;

test_score_dis = sum((f1_out<=0) & (f2_out<=0))/n_test;
% disp("Testing score = " + num2str(test_score) + " ::: Target = " + num2str(alpha))

if plot_flag
    figure,
    subplot(121)
    hold on, plot(y_stealth,'.')
    hold on, plot(thresh_1*ones(1,n_test),'+')
    title("Stealthiness")
    set(gca,'FontSize',12)
    subplot(122)
    hold on, plot(y_effect,'.')
    hold on, plot(thresh_2*ones(1,n_test),'+')
    title("Effectiveness")
    set(gca,'FontSize',12)
    
    sgtitle("Testing Performance with discriminators")
    
    dir_test1 = "test_performance/"+num2str(length(attack_indices))+"/"+num2str(attack_indices)+"/test_result_with_dis.fig";
    save(dir_test1)
end

%% Testing performance with repect to the model simulation
Z_attack_data = double(extractdata(test_out));
attack_data = ramp_attack_policy(policy_param,Z_attack_data);

sim_obj = [];

[sim_obj]  = get_simulation_object_sample_system(sim_obj,attack_data,attack_percentage);
[effect_index,stealth_index] = get_error_from_nominal(sim_obj);


f1_out = stealth_index - thresh_1;
f2_out = thresh_2 - effect_index;

test_score_sim = sum((f1_out<=0) & (f2_out<=0))/n_test;

%% save testing data
dir_dis = "test_performance/"+num2str(length(attack_indices))+"/"+num2str(attack_indices)+"/test_result_with_dis.mat";
dir_mdl = "test_performance/"+num2str(length(attack_indices))+"/"+num2str(attack_indices)+"/test_result_with_mdl.mat";
dir_spt = "test_performance/"+num2str(length(attack_indices))+"/"+num2str(attack_indices)+"/attack_support.mat";
save(dir_dis,'y_effect','y_stealth','-v7.3');
save(dir_mdl,'effect_index','stealth_index','-v7.3');
save(dir_spt,'attack_indices','-v7.3');


if plot_flag
    save('test_result','sim_obj','effect_index','stealth_index','Z_attack_data','-v7.3');
    
    figure,
    subplot(121)
    hold on, plot(stealth_index,'.')
    hold on, plot(thresh_1*ones(1,n_test))
    title("Stealthiness")
    set(gca,'FontSize',12)
    subplot(122)
    hold on, plot(effect_index,'.')
    hold on, plot(thresh_2*ones(1,n_test))
    title("Effectiveness")
    set(gca,'FontSize',12)
    
    sgtitle("Testing Performance with model simulation")

    dir_test2 = "test_performance/"+num2str(length(attack_indices))+"/"+num2str(attack_indices)+"/test_result_with_mdl.fig";
    save(dir_test2)
end