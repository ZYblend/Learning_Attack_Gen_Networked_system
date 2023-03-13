%% Run file for pipeline system
% clear 
% clc
t_sim_stop = 200;
Tsim       = 1e-3;
%% parameters for simple transmission network
n = 11;      % number of piplines: Pipe junctions are nodes, pipes are edges
c = 330;
l = ones(n,1);



%% Tree Topology
% edge diameters
D = 1.5;
D_edge = [0 D 0 0 0 0 0 0 0 0 0;
          D 0 D 0 0 0 0 0 0 0 0;
          0 D 0 D D 0 0 0 0 0 0;
          0 0 D 0 0 0 0 0 0 0 0;
          0 0 D 0 0 D 0 0 D 0 0;
          0 0 0 0 D 0 D 0 0 0 0;
          0 0 0 0 0 D 0 D 0 0 0;
          0 0 0 0 0 0 D 0 0 0 0;
          0 0 0 0 D 0 0 0 0 D D;
          0 0 0 0 0 0 0 0 D 0 D;
          0 0 0 0 0 0 0 0 D D 0];
% edge lengths
L = 10;
L_edge = [Inf L Inf Inf Inf Inf Inf Inf Inf Inf Inf;
          L Inf L Inf Inf Inf Inf Inf Inf Inf Inf;
          Inf L Inf L L Inf Inf Inf Inf Inf Inf;
          Inf Inf L Inf Inf Inf Inf Inf Inf Inf Inf;
          Inf Inf L Inf Inf L Inf Inf L Inf Inf;
          Inf Inf Inf Inf L Inf L Inf Inf Inf Inf;
          Inf Inf Inf Inf Inf L Inf L Inf Inf Inf;
          Inf Inf Inf Inf Inf Inf L Inf Inf Inf Inf;
          Inf Inf Inf Inf L Inf Inf Inf Inf L L;
          Inf Inf Inf Inf Inf Inf Inf Inf L Inf L;
          Inf Inf Inf Inf Inf Inf Inf Inf L L Inf];
% Input matrices
B_dem = -[0;0;0;0;0;0;0;0;0;0;1]; % demand channel
B_h   = -[0 0;0 0;0 0;1 0;0 0;0 0;0 0;0 1;0 0;0 0;0 0]; % well heads input channels
B     = -[1;0;0;0;0;0;0;0;0;0;0]; % control input channel

% friction factor (assumed the same for all pipes)
f = 0.0025; 

% pressure constant
K_inv = (pi^2)/(64*c^2)*f*D_edge.^5./L_edge; %( 64*(c^2)/(pi^2) )*f.*delta_x./(D.^5);

% volumetric constant
V = (pi/8)*sum(((D_edge.^2).*L_edge),2,'omitnan');


% initial condition
p_eq = load("P_eq.mat").P_eq;
p_init = p_eq;
w_eq = [-1; -5; -5; 20];

%% linearization


J_ii = @(p) -(c^2) * sum(sqrt(K_inv.*abs(l*(p.^2).' - (p.^2)*l.')).^(-1).*K_inv .* sign(l*p.' - p*l.') .* sign(l*(p.^2).' - (p.^2)*l.'),2,'omitnan') .* p ./V;
J_ij = @(p,i,j) (c^2) * sqrt(K_inv(i,j)*abs( p(j)^2-p(i)^2 ))^(-1) * K_inv(i,j) * sign(p(j)-p(i)) * sign(p(j)^2-p(i)^2) * p(j)/V(i);
J = diag(J_ii(p_eq));
for i = 1:n
    for j = 1:n
        if j ~= i
            if ~isnan(J_ij(p_eq,i,j))
                J(i,j) = J_ij(p_eq,i,j);
            end
        end
    end
end
A = J;

%% MPC design
% discrete model
Ts     = 200*Tsim;
T_MPC  = 200*Tsim;
Ad     = eye(n)+A*Ts;
Bd     = B*Ts;
B_hd   = B_h*Ts;
B_demd = B_dem*Ts;

% vecterization
h = 10;  % horizon length

% dynamics constraint
A_bar1 = kron(eye(h),-Ad) ;
A_bar2 = zeros(n*h,n);
A_bar = [A_bar1,A_bar2];
for iter = 1:h
    A_bar(n*(iter-1)+1:iter*n,iter*n+1:n*(iter+1)) = eye(n);
end
B_bar = kron(eye(h),Bd);
Bh_bar = kron(eye(h),B_hd);
B_dem_bar = kron(eye(h),B_demd);

% initialization constraint
E0 = [eye(n), zeros(n,n*h)];
E1 = [zeros(n,n*h), eye(n)];

% pack constraints
Aeq = [A_bar -B_bar;
     E0 zeros(n,h);
     E1 zeros(n,h)];
% Aeq = [A_bar -B_bar];
A_inv = pinv(Ad-eye(n),0.01);

% objective weights
%Q = diag(10*ones(size(l),1));
Q = diag([10 10 10 10 10 10 10 10 10 10 10]);
R = 0.2;
Q_bar = kron(eye(h+1),Q);
R_bar = kron(eye(h),R);
M = blkdiag(Q_bar, R_bar);

%% Unscented Kalman filter
% Noise level
R = 1e-5;  % measurement noise
Q = 1e-5;  % process noise
n_meas = 14;

%% attack
attack_start_injection = 20;  % Global attack injection start time

% Initializing attacks (zeros)
attack_start_times      = attack_start_injection*ones(n_meas,1); 
attack_full_times       = attack_start_times + 100;
attack_final_deviations = 0.0*ones(n_meas,1);