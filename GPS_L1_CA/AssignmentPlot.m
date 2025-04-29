% %% for multi-correaltor output
% for k=1:4
%     subplot(2,2,k)
%     for i=1:1000:length(trackResults(k).I_multi)
%         data=trackResults(1).I_multi{i};
%         if data(6)<0
%             data=-data;
%         end
%         plot(-0.5:0.1:0.5,data,'-');hold on;
%         scatter(-0.5:0.1:0.5,data,'o');
%     end
%     xlabel('code delay');
%     ylabel('ACF');
%     title('ACF of Multi-correlator (PRNxx, 10s interval)');
% end
%% for Weighted Least Square for positioning (elevation based)
open_gt=[22.328444770087565,114.1713630049711,3];
urban_gt=[22.3198722, 114.209101777778, 3.0];
geobasemap satellite;
error=[];
for i=1:size(navSolutions.latitude,2)
    geoplot(navSolutions.latitude(i),navSolutions.longitude(i),'r*', 'MarkerSize', 10);hold on;
end

for i=1:size(navSolutions_2.latitude,2)
    geoplot(navSolutions_2.latitude(i),navSolutions_2.longitude(i),'b*', 'MarkerSize', 10);hold on;
end
  geoplot(urban_gt(1),urban_gt(2),'o','MarkerFaceColor','y', 'MarkerSize', 10,'MarkerEdgeColor','y');hold on;
%% WLS for velocity
v=[];
for i=2:size(navSolutions.X,2)
    v=[v;navSolutions.X(i)-navSolutions.X(i-1),navSolutions.Y(i)-navSolutions.Y(i-1),navSolutions.Z(i)-navSolutions.Z(i-1)];
end
plot(1:size(navSolutions.X,2)-1,v(:,1));hold on
plot(1:size(navSolutions.X,2)-1,v(:,2));hold on
plot(1:size(navSolutions.X,2)-1,v(:,3));hold on
xlabel('epoch(s)');
ylabel('Velocity(m/s)');
legend('v_x','v_y','v_z')


%% for Kalman Filter
