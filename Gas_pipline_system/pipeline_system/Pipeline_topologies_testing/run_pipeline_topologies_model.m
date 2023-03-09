%% Run file for pipeline system
% clear 
% clc
t_sim_stop = 500;
Ts         = 1e-3;
%% parameters for simple transmission network
n = 13;      % number of piplines: Pipe junctions are nodes, pipes are edges
c = 330;

%% Linear Topology
% % edge diameters
% D = 0.8;
% D_edge = [0 D 0 0 0 0 0 0 0;
%           D 0 D 0 0 0 0 0 0;
%           0 D 0 D D 0 0 0 0;
%           0 0 D 0 0 0 0 0 0;
%           0 0 D 0 0 D D 0 0;
%           0 0 0 0 D 0 0 0 0;
%           0 0 0 0 D 0 0 D 0;
%           0 0 0 0 0 0 D 0 D;
%           0 0 0 0 0 0 0 D 0];
% 
% % edge lengths
% L = 10;
% L_edge = [Inf L Inf Inf Inf Inf Inf Inf Inf;
%           L Inf L Inf Inf Inf Inf Inf Inf;
%           Inf L Inf L L Inf Inf Inf Inf;
%           Inf Inf L Inf Inf Inf Inf Inf Inf;
%           Inf Inf L Inf Inf L L Inf Inf;
%           Inf Inf Inf Inf L Inf Inf Inf Inf;
%           Inf Inf Inf Inf L Inf Inf L Inf;
%           Inf Inf Inf Inf Inf Inf L Inf L;
%           Inf Inf Inf Inf Inf Inf Inf L Inf];
% % Input matrices
% B_dem = -[0;0;0;0;0;0;0;0;1]; % demand channel
% B_h   = -[0 0;0 0;0 0;1 0;0 0;0 1;0 0;0 0;0 0]; % well heads input channels
% B     = -[1;0;0;0;0;0;0;0;0]; % control input channel


%% Tree Topology
% % edge diameters
% D = 1.5;
% D_edge = [0 D 0 0 0 0 0 0 0 0 0;
%           D 0 D 0 0 0 0 0 0 0 0;
%           0 D 0 D D 0 0 0 0 0 0;
%           0 0 D 0 0 0 0 0 0 0 0;
%           0 0 D 0 0 D 0 0 D 0 0;
%           0 0 0 0 D 0 D 0 0 0 0;
%           0 0 0 0 0 D 0 D 0 0 0;
%           0 0 0 0 0 0 D 0 0 0 0;
%           0 0 0 0 D 0 0 0 0 D D;
%           0 0 0 0 0 0 0 0 D 0 D;
%           0 0 0 0 0 0 0 0 D D 0];
% % edge lengths
% L = 10;
% L_edge = [Inf L Inf Inf Inf Inf Inf Inf Inf Inf Inf;
%           L Inf L Inf Inf Inf Inf Inf Inf Inf Inf;
%           Inf L Inf L L Inf Inf Inf Inf Inf Inf;
%           Inf Inf L Inf Inf Inf Inf Inf Inf Inf Inf;
%           Inf Inf L Inf Inf L Inf Inf L Inf Inf;
%           Inf Inf Inf Inf L Inf L Inf Inf Inf Inf;
%           Inf Inf Inf Inf Inf L Inf L Inf Inf Inf;
%           Inf Inf Inf Inf Inf Inf L Inf Inf Inf Inf;
%           Inf Inf Inf Inf L Inf Inf Inf Inf L L;
%           Inf Inf Inf Inf Inf Inf Inf Inf L Inf L;
%           Inf Inf Inf Inf Inf Inf Inf Inf L L Inf];
% % Input matrices
% B_dem = -[0;0;0;0;0;0;0;0;0;0;1]; % demand channel
% B_h   = -[0 0;0 0;0 0;1 0;0 0;0 0;0 0;0 1;0 0;0 0;0 0]; % well heads input channels
% B     = -[1;0;0;0;0;0;0;0;0;0;0]; % control input channel

%% Cyclic Topology
% edge diameters
D = 1.5;
D_edge = [0 D D 0 0 0 0 0 0 0 0 0 0;
          D 0 0 D 0 0 0 0 0 0 0 0 0;
          D 0 0 0 D 0 0 0 0 0 0 0 0;
          0 D 0 0 0 D D 0 0 0 0 0 0;
          0 0 D 0 0 0 0 D 0 0 0 0 0;
          0 0 0 D 0 0 0 0 0 0 0 0 0;
          0 0 0 D 0 0 0 0 D 0 0 0 0;
          0 0 0 0 D 0 0 0 0 D 0 0 0;
          0 0 0 0 0 0 D 0 0 0 D 0 0;
          0 0 0 0 0 0 0 D 0 0 0 0 D;
          0 0 0 0 0 0 0 0 D 0 0 D D;
          0 0 0 0 0 0 0 0 0 0 D 0 0;
          0 0 0 0 0 0 0 0 0 D D 0 0];
% edge lengths
L = 10;
L_edge = [Inf L L Inf Inf Inf Inf Inf Inf Inf Inf Inf Inf;
          L Inf Inf L Inf Inf Inf Inf Inf Inf Inf Inf Inf;
          L Inf Inf Inf L Inf Inf Inf Inf Inf Inf Inf Inf;
          Inf L Inf Inf Inf L L Inf Inf Inf Inf Inf Inf;
          Inf Inf L Inf Inf Inf Inf L Inf Inf Inf Inf Inf;
          Inf Inf Inf L Inf Inf Inf Inf Inf Inf Inf Inf Inf;
          Inf Inf Inf L Inf Inf Inf Inf L Inf Inf Inf Inf;
          Inf Inf Inf Inf L Inf Inf Inf Inf L Inf Inf Inf;
          Inf Inf Inf Inf Inf Inf L Inf Inf Inf L Inf Inf;
          Inf Inf Inf Inf Inf Inf Inf L Inf Inf Inf Inf L;
          Inf Inf Inf Inf Inf Inf Inf Inf L Inf Inf L L;
          Inf Inf Inf Inf Inf Inf Inf Inf Inf Inf L Inf Inf;
          Inf Inf Inf Inf Inf Inf Inf Inf Inf L L Inf Inf];
% Input matrices
B_dem = -[0;0;0;0;0;0;0;0;0;0;0;0;1]; % demand channel
B_h   = -[0 0;0 0;0 0;0 0;0 0;1 0;0 0;0 0;0 0;0 0;0 0;0 1;0 0]; % well heads input channels
B     = -[1;0;0;0;0;0;0;0;0;0;0;0;0]; % control input channel


% friction factor (assumed the same for all pipes)
f = 0.0025; 

% pressure constant
K_inv = (pi^2)/(64*c^2)*f*D_edge.^5./L_edge; %( 64*(c^2)/(pi^2) )*f.*delta_x./(D.^5);

% volumetric constant
V = (pi/8)*sum(((D_edge.^2).*L_edge),2,'omitnan');


% initial condition
p_eq   = [14.1242
   14.4793
   12.6331
   14.8258
   10.9406
   16.7638
   14.0819
    8.9329
   13.2964
    6.3165
   12.4616
   14.7142
         0];
p_init = 0.8*p_eq;