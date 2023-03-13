function z_star = quad_prog_solver(M,F,Aeq,beq)
%%
% minimize (1/2) z^T*M*z + F^T z
% subject to Aeq z = beq
%
% Yu Zheng, 02/10/2023

%% parameter


%% FOC
N = [M Aeq.';
     Aeq zeros(size(Aeq,1))];

N_inv = pinv(N,0.01);
N_inv1 = N_inv(1:size(M,1),:);

z_star = N_inv1*[-F; beq];


