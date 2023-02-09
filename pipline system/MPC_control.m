function z = MPC_control(M,Aeq,beq)


z = quadprog(M,zeros(size(M,1),1),[],[],Aeq,beq);
