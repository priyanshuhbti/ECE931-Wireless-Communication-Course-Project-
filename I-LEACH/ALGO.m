% Codes Written by Priyanshu Yadav & Team  ..under the guidance of Respective Professor (Department of ECE).

% warning off all;
tic;
%% Create sensor nodes, Set Parameters and Create Energy Model %%
%Initial Parameters
n=200;     %Number of Nodes 

 %Set Parameters Sensors and Network
[Area,Model]=ALGO_setParameters(n); 

%configuration Sensors 
createRandomSen(Model,Area);  %Create a random scenario
load Locations                %Load sensor Location
Sensors=ALGO_configureSensors(Model,n,X,Y);

deadNum=0;          %Number of dead nodes
[deadNum,circlex,circley] =ALGO_plotter(Sensors,Model);

%Parameters initialization
countCHs=0;         %counter for CHs
flag_first_dead=0;  %flag_first_dead
initEnergy=0;       %Initial Energy
for i=1:n
      initEnergy=Sensors(i).E+initEnergy;
end

SRP=zeros(1,Model.rmax);    %number of sent routing packets
RRP=zeros(1,Model.rmax);    %number of receive routing packets
SDP=zeros(1,Model.rmax);    %number of sent data packets 
RDP=zeros(1,Model.rmax);    %number of receive data packets 
%total_energy_disipated=zeros(1,Model.rmax); 

Sum_DEAD=zeros(1,Model.rmax);    %initial array of sum of total dead nodes
CLUSTERHS=zeros(1,Model.rmax);   %initial array of clusterheads
AllSensorEnergy=zeros(1,Model.rmax);  %initial array of energy of nodes

%% Simulation %% 
global srp rrp sdp rdp
srp=0;          %count SRP
rrp=0;          %count RRP
sdp=0;          %count  SDP 
rdp=0;          %count RDP 

%Sink broadcast start message to all nodes
Sender=n+1;     %Sink
Receiver=1:n;   %All nodes
Sensors=sendReceivePackets(Sensors,Model,Sender,'Hello',Receiver);

% All sensor send location information to Sink .
 Sensors=disToSink(Sensors,Model);

%Save metrics
SRP(1)=srp;
RRP(1)=rrp;  
SDP(1)=sdp;
RDP(1)=rdp;

x=0;
p=0.2;
%% Main loop program
for r=1:1:Model.rmax

% Initialization  
    member=[];              %Member of each cluster in per period
    countCHs=0;             %Number of CH in per period
    %counter for bit transmitted to Bases Station and Cluster Heads
    srp=0;          %counter number of sent routing packets
    rrp=0;          %counter number of receive routing packets
    sdp=0;          %counter number of sent data packets to sink
    rdp=0;          %counter number of receive data packets by sink
    %initialization per round
    SRP(r+1)=srp;
    RRP(r+1)=rrp;  
    SDP(r+1)=sdp;
    RDP(r+1)=rdp;   
    pause(0.001)    %pause simulation
    hold off;       %clear figure
    packets_TO_BS=0;
    % Reset sensors
    Sensors=resetSensors(Sensors,Model);
    %allow to sensor to become cluster-head. LEACH Algorithm  
%     AroundClear=10;
    
    if(mod(r,round(1/p))==0) 
        for i=1:1:n
            Sensors(i).G=0;
        end
    end
    
    % plot sensors 
    [deadNum,circlex,circley] =ALGO_plotter(Sensors,Model);
    
    %Save r'th period When the first node dies
    if (deadNum>=1)      
        if(flag_first_dead==0)
            first_dead=r;
            flag_first_dead=1;
        end  
    end
    
    % cluster head election 
    %Selection Candidate Cluster Head Based on LEACH Set-up Phase
%     [TotalCH,Sensors]=ALGO_selectCH(Sensors,Model,r, circlex,circley); 
    [TotalCH,Sensors]=ALGO_selectCH(Sensors,Model,r, circlex,circley); 
    
    %Broadcasting CHs to All Sensor that are in Radio Rage CH.
    for i=1:length(TotalCH)
        
        Sender=TotalCH(i).id;
        SenderRR=Model.RR;
        Receiver=findReceiver(Sensors,Model,Sender,SenderRR);   
        Sensors=sendReceivePackets(Sensors,Model,Sender,'Hello',Receiver);
            
    end 
    
    %Sensors join to nearest CH 
    Sensors=joinToNearestCH(Sensors,Model,TotalCH);
    
%%%%%%%%%%%%%%%%%%%%%%% end of cluster head election phase %%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% steady-state phase %%%%%%%%%%%%%%%%%
    NumPacket=Model.NumPacket;
    for i=1:1:1%NumPacket 
        
        %Plotter     
        [deadNumo,circlex,circley]=ALGO_plotter(Sensors,Model);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% All sensor send data packet to  CH 
        for j=1:length(TotalCH)
            
            Receiver=TotalCH(j).id;
            Sender=findSender(Sensors,Model,Receiver); 
            Sensors=sendReceivePackets(Sensors,Model,Sender,'Data',Receiver);
           
        end
        
    end
   

%%%%%%%%%%%% send Data packet from CH to Sink after Data aggregation
    for i=1:length(TotalCH)
            
        Receiver=n+1;               %Sink
        Sender=TotalCH(i).id;       %CH 
        Sensors=sendReceivePackets(Sensors,Model,Sender,'Data',Receiver);
       
        
    end
    
%%% send data packet directly from other nodes(that aren't in each cluster) to Sink
    for i=1:n
        if(Sensors(i).MCH==Sensors(n+1).id)
            Receiver=n+1;               %Sink
            Sender=Sensors(i).id;       %Other Nodes 
            Sensors=sendReceivePackets(Sensors,Model,Sender,'Data',Receiver);
            

        end
    end
  
%% STATISTICS
     
    Sum_DEAD(r+1)=deadNum;
    
    SRP(r+1)=srp;
    RRP(r+1)=rrp;  
    SDP(r+1)=sdp;
    RDP(r+1)=rdp;
    
    CLUSTERHS(r+1)=countCHs;
    
    alive=0;
    SensorEnergy=0;
    for i=1:n
        if Sensors(i).E>0
            alive=alive+1;
            SensorEnergy=SensorEnergy+Sensors(i).E;
        end
    end
    AliveSensors(r)=alive; %#ok
    
    SumEnergyAllSensor(r+1)=SensorEnergy; %#ok
    
    AvgEnergyAllSensor(r+1)=SensorEnergy/alive; %#ok
    
    ConsumEnergy(r+1)=(initEnergy-SumEnergyAllSensor(r+1))/n; %#ok
    
    En=0;
    for i=1:n
        if Sensors(i).E>0
            En=En+(Sensors(i).E-AvgEnergyAllSensor(r+1))^2;
        end
    end
    
    Enheraf(r+1)=En/alive; %#ok
    
    title(sprintf('Round=%d,Dead nodes=%d', r+1, deadNum)) 
    
   %dead
   if(n==deadNum)
       
       lastPeriod=r;  
       break;
       
   end


STATISTICS1.Alive(r+1)=n-deadNum;
STATISTICS1.Energy(r+1)=SumEnergyAllSensor(r+1);
STATISTICS1.CLUSTERHS(r+1) = CLUSTERHS(r+1);
STATISTICS1.RDP(r+1) = RDP(r+1)*rdp;
x=r+1;
end % for r=0:1:rmax


r=1:x-1;
figure(2)
plot(r,STATISTICS1.Alive(r+1));
xlabel 'Rounds';
ylabel 'No of live sensor Nodes';
title('Life time of Sensor Nodes')


figure(3)
plot(r,STATISTICS1.Energy(r+1));
xlabel 'Rounds';
ylabel 'Energy(in j)';
title('Avergae Residual energy ');


figure(4)
plot(r,STATISTICS1.RDP(r+1));
xlabel 'Rounds';
ylabel 'No. of Data packet sent';
title('Throughput ');


figure
plot(r,STATISTICS1.Alive(r+1),r,STATISTICS.Alive(r+1),'linewidth',1.5);
% hold on;
% plot(r,STATISTICS.Alive(r+1),'linewidth',1.5);
legend("PROPOSED","LEACH")
xlabel 'Rounds';
ylabel 'No of live sensor Nodes';
title('Life time of Sensor Nodes')

figure
plot(r,STATISTICS1.Energy(r+1),r,STATISTICS.Energy(r+1),'linewidth',1.5);
legend("PROPOSED","LEACH")
xlabel 'Rounds';
ylabel 'Energy(in j)';
title('Average Residual energy ');

figure
plot(r,STATISTICS1.RDP(r+1),r,STATISTICS.RDP(r+1),'linewidth',1.5);
legend("PROPOSED","LEACH")
xlabel 'Rounds';
ylabel 'No. of Data packet sent';
title('Throughput ');

disp('End of Simulation');
toc;

filename=sprintf('leach%d.mat',n);

%% Save Report
save(filename);
