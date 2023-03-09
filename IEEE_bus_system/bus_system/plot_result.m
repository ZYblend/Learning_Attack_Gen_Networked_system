%% plot result

time = out.critical_measurement.Time;
x = out.critical_measurement.Data;
r = out.residual.Data;
nominal_index = load("nominal_index.mat");
yc_nominal = nominal_index.yc_nominal;
% p = reshape(p,size(p,1),size(p,3)).';

%%
figure
subplot(5,1,1)
plot(time,yc_nominal(:,1),'LineWidth',2);
hold on, plot(time,x(:,1),'LineWidth',2);
ylabel('\delta_1')

subplot(5,1,2)
plot(time,yc_nominal(:,2),'LineWidth',2);
hold on, plot(time,x(:,2),'LineWidth',2);
ylabel('\delta_2')

subplot(5,1,3)
plot(time,yc_nominal(:,3),'LineWidth',2);
hold on, plot(time,x(:,3),'LineWidth',2);
ylabel('\delta_3')

subplot(5,1,4)
plot(time,yc_nominal(:,4),'LineWidth',2);
hold on, plot(time,x(:,4),'LineWidth',2);
ylabel('\delta_4')

subplot(5,1,5)
plot(time,yc_nominal(:,5),'LineWidth',2);
hold on, plot(time,x(:,5),'LineWidth',2);
ylabel('\delta_5')

%%
figure 
plot(time,r);