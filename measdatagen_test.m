
%Create motion model
T = 1;
sigma_q = 1;
motion_model = motionmodel.cvmodel(T,sigma_q);

%Create measurement model
sigma_r = 1;
meas_model = measmodel.cvmeasmodel(sigma_r);

%Create tracking model
P_D = 0.9;
lambda_c = 10;
range_c = [-100 100;-100 100];
sensor_model = modelgen.sensormodel(P_D,lambda_c,range_c);

nbirths = 3;
K = 10;

tbirth = zeros(nbirths,1);
tdeath = zeros(nbirths,1);
initial_state.x = zeros(motion_model.d,nbirths);
initial_state.x(:,1) = [0; 0; 0; -10];        tbirth(1) = 1;   tdeath(1) = 5;
initial_state.x(:,2) = [400; -600; -10; 5];   tbirth(2) = 2;   tdeath(2) = 8;      
initial_state.x(:,3) = [-800; -200; 20; -5];  tbirth(3) = 3;   tdeath(3) = K;
ground_truth = modelgen.groundtruth(nbirths,initial_state.x,tbirth,tdeath,K);

%Create object data
objectdata = objectdatagen(ground_truth,motion_model,0);

%Create measurement data
measdata = measdatagen(objectdata,sensor_model,meas_model);

%Visualize the results
%---------------------
%measurement
t = length(measdata);
samples_t = zeros(t,1);
measdata_array = [];  %measurememt array (clutter + obj originated meas)

%vidObj_clutter = VideoWriter('Clutter.avi');
%vidObj_obj_detections = VideoWriter('Obj_Detections_and_Clutter.avi');
%vidObj_clutter.FrameRate = 1;
%open(vidObj_clutter); 
filename = 'Clutter.gif';
fID_clutter = 1;

for idx = 1:t
    array = cell2mat(measdata(idx));
    measdata_array = [measdata_array , array];
    samples = length(cell2mat(measdata(idx)));
    samples_t(idx,1) = samples;
    no_obj = objectdata.N(idx);   %number of objects
    
    X_obj = array(1,1:no_obj);
    Y_obj = array(2,1:no_obj);
    X_clutter = array(1, (no_obj + 1):end);
    Y_clutter = array(2, (no_obj + 1):end);
    
    pause(1)
    
    figure(fID_clutter);
    subplot(2,1,1)
    plot(X_obj,Y_obj, '*','color','red');
    hold on;
    plot(X_clutter,Y_clutter, '*', 'color', 'blue');
    grid on
    xlabel('m');
    ylabel('m');
    legend('Obj Originated meas','Clutter', 'Location', 'best')
    %axis equal;
    title(strcat('time = ',num2str(idx)));
    set(gca, 'XLim',[-700 700]);
    set(gca, 'YLim',[-700 700]);
    hold off;
    
    subplot(2,1,2)
    plot(X_obj,Y_obj, '*','color','red');
    hold on;
    grid on
    xlabel('m');
    ylabel('m');
    %axis equal;
    title(strcat('Object Detections ' ,'time = ',num2str(idx)));
    set(gca, 'XLim',[-700 700]);
    set(gca, 'YLim',[-700 700]);
    
    drawnow
    
    frame = getframe(fID_clutter); % 'gcf' can handle if you zoom in to take a movie.
    image = frame2im(frame);
    [imind,cm] = rgb2ind(image,256);
    % Write to the GIF File 
    if idx == 1 
        imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
    else 
        imwrite(imind,cm,filename,'gif','WriteMode','append'); 
    end 
    %writeVideo(vidObj_clutter, frame);
    
end

%close(vidObj_clutter);
