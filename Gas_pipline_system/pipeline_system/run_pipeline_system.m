
%% Run file for pipeline system
% clear 
% clc
t_sim_stop = 2000;
%% parameters for simple transmission network
n = 4;      % number of piplines: Pipe junctions are nodes, pipes are edges
c = 330;

% edge diameters
D12 = 0.8;
D23 = 0.5;
D34 = 1.5;
D_edge = [0 D12 0 0;
     D12 0 D23 0;
     0 D23 0 D34;
     0 0 D34 0];

% edge lengths
L12 = 10;
L23 = 10;
L34 = 10;
L_edge = [inf L12 inf inf;
     L12 inf L23 inf;
     inf L23 inf L34;
     inf inf L34 inf];

% friction factor (assumed the same for all pipes)
f = 0.0025; 

% pressure constant
K_inv = (pi^2)/(64*c^2)*f*D_edge.^5./L_edge; %( 64*(c^2)/(pi^2) )*f.*delta_x./(D.^5);

% volumetric constant
V = (pi/8)*sum(((D_edge.^2).*L_edge),2,'omitnan');


% Input matrices
B_dem = -[0;0;0;1]; % demand channel
B_h   = -[0 0;1 0;0 1;0 0]; % well heads input channels
B     = -[1;0;0;0]; % control input channel

% initial condition
p_init = zeros(n,1);


%% Equilibrium analysis
l = ones(n,1);
% 
% p_eq = [90;70;70;50];  %N/m^2
% w_eq = c^2*(sqrt(K_inv.*abs(l*(p_eq.^2).' - (p_eq.^2)*l.')).*sign(l*p_eq.' - p_eq*l.')*l)./V;
% 
% w_bar = [-48;-1;-1;50];
% F_approx = @(p) 1e10*(sqrt(K_inv.*abs(l*(p.^2).' - (p.^2)*l.')).*tanh(50*(l*p.' - p*l.'))*l - (1/c^2)*w_bar.*V) ;
% p0 = fsolve(F_approx,p_eq)
% 
% F = @(p) 1e6*(sqrt(K_inv.*abs(l*(p.^2).' - (p.^2)*l.')).*sign(l*p.' - p*l.')*l - (1/c^2)*w_bar.*V) ;
% p02 = fsolve(F,p0)
% 
% c^2*(sqrt(K_inv.*abs(l*(p0.^2).' - (p0.^2)*l.')).*sign(l*p0.' - p0*l.')*l)./V
% c^2*(sqrt(K_inv.*abs(l*(p02.^2).' - (p02.^2)*l.')).*sign(l*p02.' - p02*l.')*l)./V

% desired flows
w_1_3 = [20;5;5];
d_1_3 = w_1_3.*V(1:3)/c^2;

w_demand = c^2*sum(d_1_3)/V(4);

P4 = 50;
P3 = sqrt(P4^2+(1/K_inv(3,4))*(sum(d_1_3)^2));
P2 = sqrt(P3^2+(1/K_inv(2,3))*(sum(d_1_3(1:2))^2));
P1 = sqrt(P2^2+(1/K_inv(1,2))*(sum(d_1_3(1))^2));

p_eq = [P1;P2;P3;P4];  %N/m^2
w_eq = c^2*(sqrt(K_inv.*abs(l*(p_eq.^2).' - (p_eq.^2)*l.')).*sign(l*p_eq.' - p_eq*l.')*l)./V;

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
% length(A) - rank(ctrb(A,B))


%% pole placement control (w_h, w_dem cannot be vanished)
poles = [-1; -2; -4; -5];
K_control = place(A,B,poles);

%% MPC design
% discrete model
Ts = 0.05;
Ad = eye(n)+A*Ts;
Bd = B*Ts;
B_hd = B_h*Ts;
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
Q = diag([10 10 10 10]);
R = 0.2;
Q_bar = kron(eye(h+1),Q);
R_bar = kron(eye(h),R);
M = blkdiag(Q_bar, R_bar);


%% Unscented Kalman filter
% Noise level
R = 1e-5;  % measurement noise
Q = 1e-5;  % process noise
n_meas = 7;


%% attack
attack_start_injection = 20;  % Global attack injection start time

% Initializing attacks (zeros)
attack_start_times      = attack_start_injection*ones(n_meas,1); 
attack_full_times       = attack_start_times + 100;
attack_final_deviations = 0.0*ones(n_meas,1);


