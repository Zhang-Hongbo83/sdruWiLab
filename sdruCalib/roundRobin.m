clear all; clc;

%Kill all existing processes
system('ssh root@monadnock.ece.wpi.edu "tb -dest k9 -act killallp -u traviscollins">NUL 2>NUL');
system('ssh root@monadnock.ece.wpi.edu "tb -dest badwolf -act killallp -u traviscollins">NUL 2>NUL');
system('ssh root@monadnock.ece.wpi.edu "tb -dest thedoctor -act killallp -u traviscollins">NUL 2>NUL');

%Sync Code
disp('Syncing code');
system('ssh root@monadnock.ece.wpi.edu "tb -u traviscollins -dest k9 -act sync">NUL 2>NUL');
system('ssh root@monadnock.ece.wpi.edu "tb -u traviscollins -dest badwolf -act sync">NUL 2>NUL');
system('ssh root@monadnock.ece.wpi.edu "tb -u traviscollins -dest thedoctor -act sync">NUL 2>NUL');
disp('Done Syncing');

%hostnames = {'k9','badwolf','thedoctor'};%,'tyco'};
hostnames = {'thedoctor','k9','badwolf'};%,'tyco'};

Nodes = length(hostnames);

% Change from hostnames to node #'s
for i = 1:Nodes
    disp([hostnames{i},' is reassigned to node#: ',num2str(i)]);
end

% Make table for other functions to use
nodeTable_offsets = zeros(Nodes, Nodes);

index = 0;

for i = 1:Nodes
    % Kill transmitter if running
    killFreqCalTX( hostnames{i} );
    
    % Start Transmitter on a given node
    disp(['Starting transmitter on node: ',num2str(i),' (',hostnames{i},')']);
    runFreqCalTX( hostnames{i} );
    pause(4);
    
    % Cycle through reception nodes
    for j = 1:Nodes
        
        % Cannot calibrate to own radio :)
        if i==j
           continue; 
        end
        
        % Measure offset at give node
        disp(['Starting receiver on node: ',num2str(j),' (',hostnames{j},')']);
        offset = runFreqCalRX( hostnames{j} );        
        
        % Save measurement
        index = index + 1;
        nodeTable(index).Transmitter = hostnames{i};
        nodeTable(index).Receiver = hostnames{j};
        nodeTable(index).Offset = offset;

        nodeTable_offsets(j,i) = offset;
        
    end
    
    % Kill transmitter
    disp(['Stopping transmitter on node: ',num2str(i),' (',hostnames{i},')']);
    killFreqCalTX( hostnames{i} );
    
end


% Print out offsets
for i=1:length(nodeTable)
    fprintf('###Pair %d###\n',i);
    disp(nodeTable(i));
end

% Publish for other scripts to use
save('offsets.mat','nodeTable_offsets','hostnames');



 