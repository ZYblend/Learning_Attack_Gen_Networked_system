%% plot result

time = out.critical_measurement.Time;
p = out.critical_measurement.Data;
p = reshape(p,size(p,1),size(p,3)).';

%%
figure
subplot(2,2,1)
yline(p_eq(1),'k--','LineWidth',2);
hold on, plot(time,p(:,1),'LineWidth',2);
ylabel('p_1')

subplot(2,2,2)
yline(p_eq(2),'k--','LineWidth',2);
hold on, plot(time,p(:,2),'LineWidth',2);
ylabel('p_2')

subplot(2,2,3)
yline(p_eq(3),'k--','LineWidth',2);
hold on, plot(time,p(:,3),'LineWidth',2);
ylabel('p_3')

subplot(2,2,4)
yline(p_eq(4),'k--','LineWidth',2);
hold on, plot(time,p(:,4),'LineWidth',2);
ylabel('p_44')