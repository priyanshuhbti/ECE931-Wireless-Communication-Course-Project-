function [deadNum,circlex,circley]=ALGO_plotter(Sensors,Model)
    deadNum=0;
    n=Model.n;
    
    %creating circular clusters
    numRX=Model.numRx;   %number of segments on each side
    circlex=zeros(numRX,numRX);   %xunit
    circley=zeros(numRX,numRX);   %yunit
    for i=1:1:numRX
        for j=1:1:numRX
            %center coordinates
            circlex(i,j)=(Model.dr/2)+((j-1)*Model.dr);  
            circley(i,j)=(Model.dr/2)+((i-1)*Model.dr);  
        end
    end
   
    r=Model.dr/2;
    angle=0:pi/50:2*pi;
    xp=r*cos(angle);
    yp=r*sin(angle);
    for i=1:1:numRX
         for j=1:1:numRX
            plot(circlex(i,j)+xp,circley(i,j)+yp,'g');
            hold on;
            axis('equal');
         end
    end    
        
    for i=1:n
        %check dead node
        if (Sensors(i).E>0)
            
            if(Sensors(i).type=='N' )      
                plot(Sensors(i).xd,Sensors(i).yd,'ko', 'MarkerSize', 5, 'MarkerFaceColor', 'k');
               % text(Sensors(i).xd+1,Sensors(i).yd-1,num2str(i));
            else %Sensors.type=='C'       
                plot(Sensors(i).xd,Sensors(i).yd,'ko', 'MarkerSize', 5, 'MarkerFaceColor', 'r');
              %  text(Sensors(i).xd+1,Sensors(i).yd-1,num2str(i));
            end
            
        else
            deadNum=deadNum+1;
            plot(Sensors(i).xd,Sensors(i).yd,'ko', 'MarkerSize',5, 'MarkerFaceColor', 'w');
           % text(Sensors(i).xd+1,Sensors(i).yd-1,num2str(i));
        end
        
        hold on;
        
    end 
    plot(Sensors(n+1).xd,Sensors(n+1).yd,'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
    text(Sensors(n+1).xd+1,Sensors(n+1).yd-1,'Sink');
    axis square

end