%% Resilient Observer Initializer
%   - Loads bus data
%   - Defines network Laplacian
%   - Defines discretize system matrices
%   - Resilient Observer
%   - Attack Model
%   - Bad Data Detection
%   - Auxiliary Model

% Jan. 2020 (initial version)
% Olugbenga Moses Anubi
% Carlos A. Wong
% Satish Vedula

% Jan. 2021
% Yu Zheng

%% Parameter Setup
% clear variables
% close all
% clc

% addpath('Resilient_Optimizer')
% addpath('Attack_Generators')

%% Data Loading
[baseMVA, bus, gen, branch, ~, ~, X_d, H, Dg] = bus14_PSCAD;
[~,I_sort]  = sort(bus.type,'descend');
bus_no      = (1:length(bus.type));
% to be used for rearranging buses with generator buses first

%% Dimension Variables
n_gen       = size(gen,1); % number of generators
n_bus       = size(bus,1); % number of buses
n_states    = 2*n_gen;
p           = n_states + n_bus;
n_meas      = n_gen + n_bus;  % number of measurements


%% Network Laplacian
% relabelling the nodes such that generator nodes come first
fbus_new = interp1(bus_no(I_sort),bus_no,branch.fbus);
tbus_new = interp1(bus_no(I_sort),bus_no,branch.tbus);

sus_weighted_graph = graph(fbus_new,...
                           tbus_new,...
                           branch.x);
Adj                = adjacency(sus_weighted_graph,'weighted');
%   Adjacency of the susceptance weighted graph
Inc                = full(incidence(sus_weighted_graph));
Lap                = diag(sum(Adj)) - Adj; % laplacian
Susc               = diag(1./branch.x);

%% Admitance Matrix (Ybus)
% Assume G = 0 then the network is lossles
L_gg   = diag(1./X_d);
L_gl   = [diag(1./X_d) zeros(n_gen, n_bus-n_gen)];
L_lg   = L_gl.';
L_ll   = -blkdiag(L_gg,zeros(n_bus-n_gen)) - Lap;
LL = [L_gg L_gl; L_lg L_ll];
% sanity check
disp('Sanity Check: Positive?')
disp(eig(L_gg-(L_gl*(L_ll\L_lg))).')

%% Inertia Matrix
% Reference data
f_ref = 60;             % reference frequency in Hz
% S_base  = baseMVA;      % 3-phase base rating for the generators MVA
omega_r = 2*pi*f_ref;   % reference frequency in rad/sec

Mass_gen = 2*H/omega_r;
M = diag(Mass_gen);     % mass matrix for the generators
Dg = diag(Dg);          % damping matrix for the generators

%% Power Flow
V = ones(n_bus,1);      % voltage @ each bus assumed to be 1 p.u.
% Pst(theta) - power injected into network at s onto line h to bus h
R = diag(exp(abs(Inc).'*log(V)))*Susc*Inc.';
% Pnw(theta) - power flow for net power flowing into network        - n_bus
J = -Inc*R;

%% System Matrices
%%%% state update matrix                        - 2*n_gen x 2*n_gen
A_bar = [zeros(n_gen)                   eye(n_gen);
        -M\(L_gg-(L_gl*(L_ll\L_lg)))    -M\Dg];
%%%% input matrix                               - 2*n_gen x n_gen+n_bus
%        Pg           Pd
B_bar = [zeros(n_gen) zeros(n_gen, n_bus);
        inv(M)       -M\(L_gl/L_ll)];
%%%% output matrix                              - 
%%% in terms of x_bar = [delta; omega];
C_omega = [zeros(n_gen)     eye(n_gen)];
C_theta = [-L_ll\L_lg       zeros(n_bus,n_gen)];
% theta will not be an output
C_Pnet  = [-J*(L_ll\L_lg)   zeros(n_bus,n_gen)];
% Does not consider the power injected from generators
C_bar   = [C_omega; C_theta; C_Pnet];
C_obsv  = [C_omega; C_Pnet];

%%%% feedforward matrix
D_omega = zeros(n_gen,n_gen+n_bus);
D_theta = [zeros(n_bus,n_gen) eye(n_bus)];
D_Pnet  = [zeros(n_bus,n_gen) -J/L_ll];
D_bar   = [D_omega; D_theta; D_Pnet];
D_obsv  = [D_omega; D_Pnet];

%% Discretized System Model
T_sample = 0.01;
[A_bar_d, B_bar_d] = discretize_linear_model(A_bar,B_bar,T_sample);
C_obsv_d = C_obsv;
D_obsv_d = D_obsv;

disp('eigenvalues of linearized A')
disp(eig(A_bar_d).')

%% system matrix unit testing
%controllability and observability
disp('controllability')
disp(rank(ctrb(A_bar_d,B_bar_d))) % fully controllable with PID controller
disp('observability')
disp(rank(obsv(A_bar_d,C_obsv_d))) % fully observable

%% Observer Dynamics
%%% Pole Placement
P = [0.247; 0.144; 0.412; 0.255; 0.196; 0.262; 0.138; 0.153; 0.476; 0.482];
L_obsv = place(A_bar_d.',C_obsv_d.',P).';
disp('discrete observer (A-L*C) eigenvalues: negative?')
disp(eig(A_bar_d-L_obsv*C_obsv_d).')
 
%% Simulation Initialization
x0          = zeros(n_states,1);
x0_hat      = x0;
load_buses  = [zeros(n_gen,1); ones(n_bus-n_gen,1)];

T_final = 8;

%% Bad Data Detection
BDD_thresh = 0.5e-1;  % Bad data detection tolerance
[U,~,~] = svd(C_obsv_d);
U2 = U(:,n_states+1:end);

%% attack
attack_start_injection = 2;  % Global attack injection start time

% Initializing attacks (zeros)
attack_start_times      = attack_start_injection*ones(n_meas,1); 
attack_full_times       = attack_start_times + 4;
if attack_type == "ramp"
    attack_final_deviations = zeros(n_meas,2);   % for ramp
    attack_final_deviations(:,1) = ones(n_meas,1);
elseif attack_type == "sin" || attack_type =="pulse"
    attack_final_deviations = zeros(n_meas,2);  % for sin attack
end