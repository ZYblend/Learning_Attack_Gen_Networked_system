clear all
clc

%% define hyperparameters
attack_percentage = 1;
% choose network topology: linear, tree, cyclic
topology = "cyclic";

Run_sim;
tot_test = 180;
n_test = tot_test;

thresh_1 = 0.02;  % threshold for stealthiness
thresh_2 = 65;  % threshold for effectivness
thresholds = [thresh_1,thresh_2];

n_batch = 10;

stealth_batch = zeros(tot_test,n_batch);
effect_batch = zeros(tot_test,n_batch);
test_score_sim = zeros(n_batch,1);

for iter = 1:n_batch
    % load network
    dir_net = "training_performance/"+num2str(length(attack_indices))+"/"+num2str(attack_indices)+"/PostTraining_Epoch1Batch"+num2str(iter)+".mat";
    load_batch = load(dir_net);
    gen_net = load_batch.gen_net;

    % test
    inp_size = gen_net.Layers(1, 1).InputSize;

    Z_test        = rand(inp_size,n_test,"single");   % uniformly random noise as input
    Z_tet_dlarray = dlarray(Z_test,"CB");                         % covert to dlarray
    
    test_out = double(forward(gen_net,Z_tet_dlarray));

    Z_attack_data = double(extractdata(test_out));
    attack_data = ramp_attack_policy(policy_param,Z_attack_data);
    
    sim_obj = [];
    
    [sim_obj]  = get_simulation_object_sample_system(sim_obj,attack_data,attack_percentage,topology);
    [effect_batch(:,iter),stealth_batch(:,iter)] = get_error_from_nominal(sim_obj);
    
    
    f1_out = stealth_batch(:,iter) - thresh_1;
    f2_out = thresh_2 - effect_batch(:,iter);
    
    test_score_sim(iter) = sum((f1_out<=0) & (f2_out<=0))/n_test;
end

%% plotting
figure
subplot(1,2,1)
yline(thresh_1,'k')
hold on, boxplot(stealth_batch);
xlabel('Batch')
ylabel('Stealthiness')
subplot(1,2,2)
yline(thresh_2,'k')
hold on, boxplot(effect_batch)
xlabel('Batch')
ylabel('Effectiveness')

save('test_performance.mat','test_score_sim','effect_batch','stealth_batch','-v7.3');
