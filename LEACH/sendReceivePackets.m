function Sensors=sendReceivePackets(Sensors,Model,Sender,PacketType,Receiver)
   global srp rrp sdp rdp 
   sap=0;      % Send a packet
   rap=0;      % Receive a packet
   if (strcmp(PacketType,'Hello'))
       PacketSize=Model.HpacketLen;
   else
       PacketSize=Model.DpacketLen;
   end
   
   %Energy dissipated from Sensors for Send a packet 
   for i=1:length( Sender)
       
      for j=1:length( Receiver)
          

            distance=sqrt((Sensors(Sender(i)).xd-Sensors(Receiver(j)).xd)^2 + ...
               (Sensors(Sender(i)).yd-Sensors(Receiver(j)).yd)^2 );  

            if (distance>Model.do)

                Sensors(Sender(i)).E=Sensors(Sender(i)).E- ...
                    (Model.ETX*PacketSize + Model.Emp*PacketSize*(distance^4));

                % Sent a packet
                if(Sensors(Sender(i)).E>0)
                    sap=sap+1;                 
                end

            else

                Sensors(Sender(i)).E=Sensors(Sender(i)).E- ...
                    (Model.ETX*PacketSize + Model.Efs*PacketSize*(distance^2));

                % Sent a packet
                if(Sensors(Sender(i)).E>0)
                    sap=sap+1;                 
                end

            end
          
      end
      
   end
   
   %Energy dissipated from sensors for Receive a packet
   for j=1:length( Receiver)
        Sensors(Receiver(j)).E =Sensors(Receiver(j)).E- ...
            ((Model.ERX + Model.EDA)*PacketSize);
         
   end   
   
   for i=1:length(Sender)
       for j=1:length(Receiver)

            %Received a Packet
            if(Sensors(Sender(i)).E>0 && Sensors(Receiver(j)).E>0)
                rap=rap+1;
            end
       end 
   end
   
    if (strcmp(PacketType,'Hello'))
        srp=srp+sap;
        rrp=rrp+rap;
    else       
        sdp=sdp+sap;
        rdp=rdp+rap;
    end
   
end
