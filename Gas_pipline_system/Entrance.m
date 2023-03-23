close all
clear all
clc

attack_percentage = 1;
% choose network topology: linear, tree, cyclic
topology = "cyclic";

Run_sim;
workshop(attack_percentage,topology);