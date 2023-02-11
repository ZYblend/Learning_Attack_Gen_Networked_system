function net = create_dl_network(inp_size,activation_fcns,n_neurons)
%% function net = create_dl_network(inp_size,activation_fcns,n_neurons)
% create deep learning object for neural network
% current support activation functions:
%                                       sigmoid, relu, tanh
% Inputs:
%        inp_size       : [scalar] input size
%        activation_fcns: [1-by-n_layers] string array of activation functions for hidden layers and output layer
%        n_neurons      : [1-by-n_layers] array of number of neurons at hidden layers and output layer
% Output: 
%        net: [dl object] dl object of neural network
%
% Author: Yu Zheng, Florida State University, 08.19.2022

%% build dl object for network
layers = [featureInputLayer(inp_size,"Name","input")];

n_layers = size(activation_fcns,2);
for i_layer=1:n_layers
    if activation_fcns(i_layer) == 'relu'
        layer_i = [fullyConnectedLayer(n_neurons(i_layer),"Name","fc_"+num2str(i_layer))
                   reluLayer("Name","relu"+num2str(i_layer))];
        layers = [layers;layer_i];
    elseif activation_fcns(i_layer) == 'sigmoid'
        layer_i = [fullyConnectedLayer(n_neurons(i_layer),"Name","fc_"+num2str(i_layer))
                   sigmoidLayer("Name","sig"+num2str(i_layer))];
        layers = [layers;layer_i];
    elseif activation_fcns(i_layer) == 'tanh'
        layer_i = [fullyConnectedLayer(n_neurons(i_layer),"Name","fc_"+num2str(i_layer))
                   tanhLayer("Name","tanh"+num2str(i_layer))];
        layers = [layers;layer_i];
    elseif activation_fcns(i_layer) == 'linear'
        layer_i = [fullyConnectedLayer(n_neurons(i_layer),"Name","fc_"+num2str(i_layer))];
        layers = [layers;layer_i];
    end
end

net = dlnetwork(layers);