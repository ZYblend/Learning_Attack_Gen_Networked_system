function net = train_regression_network(net,dataset,loss_curve_param,i_epoch,figure_name)
%% function net = train_regression_network(net,dataset,loss_curve_param)
% Use this function to train regression network with mean square error loss function
% Inputs:
%        - net: dl object of neural network
%        - dataset: {input, output} 
%        - loss_curv_param: {loss_fig_dis,disLossTrain,start}
%          How to use the loss curve: 
%                                     loss_fig_dis = figure;
%                                     disLossTrain = animatedline(Color=C(2,:));
%                                     ylim([0 inf])
%                                     xlabel("Iteration")
%                                     ylabel("Loss")
%                                     grid on
%
% Yu Zheng, Florida state University, 08/31/2022

%% training parameters 
iteration       = 0;
mini_batch_size = 1000;

% initialize Adam optimizer
learnRate = 0.0002;
gradientDecayFactor = 0.5;
squaredGradientDecayFactor = 0.999;

trailingAvg = [];
trailingAvgSq = [];

% dataset
Z_input = dataset{1,1};
Z_output = dataset{1,2};

n_batch = 200;
% n_samples = round(n_batch*mini_batch_size);
% n_batch  = round(n_samples/mini_batch_size);

%% plot parameters
loss_fig_dis = loss_curve_param{1,1};
disLossTrain = loss_curve_param{1,2};
start = loss_curve_param{1,3};


%% training loop
for ind = 1:n_batch
    iteration = iteration+1;

    % Getting mini-batch input data
%     idx = ind:min(ind+mini_batch_size-1,n_samples);
    idx = sort(randperm(size(Z_output,2),mini_batch_size));
    input_iter = Z_input(:,idx);
    output_iter = Z_output(:,idx);
    % calculate loss and gradients
    [gradients,net_state,loss] = dlfeval(@model_loss,net,input_iter,output_iter); % forward propogation, simulation, loss calculation, gradient calculation 
    net.State = net_state;                    % update network state
    
    % Update the network parameters using the Adam optimizer.
    [net,trailingAvg,trailingAvgSq] = adamupdate(net, gradients, ...
        trailingAvg, trailingAvgSq, iteration, ...
        learnRate, gradientDecayFactor, squaredGradientDecayFactor);

    % Display the training progress.
    figure(loss_fig_dis)
    D = duration(0,0,toc(start),Format="hh:mm:ss");
    addpoints(disLossTrain,(i_epoch-1)*n_batch+iteration,double(loss))
    title(figure_name + "epoch: " + 1 + ", Elapsed: " + string(D))
    drawnow
end
% % Display the training progress.
% figure(loss_fig_dis)
% D = duration(0,0,toc(start),Format="hh:mm:ss");
% addpoints(disLossTrain,i_epoch,double(loss))
% title(figure_name + "epoch: " + 1 + ", Elapsed: " + string(D))
% drawnow

function [gradients,states,loss] = model_loss(net,input,target_output)

[output, states] = forward(net,input);
% loss = sum((output - target_output).^2) / mini_batch_size;
loss = mse(output,target_output);

gradients = dlgradient(loss,net.Learnables);