function x_next = myStateTransitionFcnTopology(x,w)

%% unpack input
p = x(1:11);
w_ex = x(12:end);
w_h = w_ex(1:2);
w_dem = w_ex(3);

%% params
c = 330;
Ts = 1e-3;

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


%% Dynamics
p_sq = p.^2;
l    = ones(length(p),1);  % vector of ones
Psi = sqrt(K_inv.*abs(l*p_sq.' - p_sq*l.')).*sign(l*p.' - p*l.');

p_dot = c^2*(Psi*l)./V + B_h*w_h + B_dem*w_dem + B*w;


%%  Discrete form
p_next = p + p_dot*Ts;
w_next = w_ex;

x_next = [p_next; w_next];