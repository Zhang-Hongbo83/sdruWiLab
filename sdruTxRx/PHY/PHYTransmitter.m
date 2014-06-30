classdef PHYTransmitter < OFDMPHYBase
    % Untitled Add summary here
    %
    % This template includes the minimum set of functions required
    % to define a System object with discrete state.
    
    properties (Nontunable)
        % Public, tunable properties.
	CenterFrequency = 2.24e9;
	HWAttached = false;
	
    end
    
    properties (Access = private)

	pSDRuTransmitter
	pCRCGen
	pMod

    end
    
    methods (Access = protected)
        function setupImpl(obj,~)


		% Create Preamble data
            	CreatePreambles(obj);
            
           	 % Create Modulator objects
            	CreateDemodulators(obj);

		USRPADCSamplingRate = 100e6;
            	InterpolationFactor = USRPADCSamplingRate/obj.SamplingFrequency;  

		% Setup transmitter
		if obj.HWAttached
		Obj.pSDRuTransmitter = comm.SDRuTransmitter('192.168.10.2', ...
    			'CenterFrequency',      obj.CenterFrequency, ...
    			'InterpolationFactor',  InterpolationFactor,...
    			'Gain',                 25);
		end

		% CRC Generator
		obj.pCRCGen = comm.CRCGenerator([1 0 0 1], 'ChecksumsPerFrame',1);


		% Construct modulator for each subcarrier
		obj.pMod = comm.BPSKModulator; % BPSK


        end
        
        function y = stepImpl(obj,data)
           
		numFrames = 1; 
		% Transmit frames 1 at a time
		for frames = 1:numFrames
			if obj.HWAttached
			step(obj.pSDRuTransmitter,data(frame,:));%1 Frame per row
			else
			fprintf('Pew pew\n');
			end
		end
		y = 1;

        end
    end

	methods
	function [frame,padBits,numDataSymbols,frameLength] = CreateOFDMFrame( obj, payloadMessage )

		
		% payloadMessage: Will always be a matrix
		% The size must be fixed between calls, they may be a 
		% workaround for this with varsize, but not sure yet
		%
		% This assumes the input is a matrix of bits (doubles 
		% 1's and 0's)		

		% Use string as message
		%originalData = OFDMletters2bits(obj,payloadMessage);
		originalData = reshape(payloadMessage.',size(payloadMessage,1)*size(payloadMessage,2),1);

		% Generate CRC
		dataWithCRC = step(obj.pCRCGen, originalData);% Add CRC

		% Apply modulator for each subcarrier
		modData = step(obj.pMod, dataWithCRC);

		% Pad IFFT
		padBits = obj.numCarriers - mod(length(modData),obj.numCarriers);
		if padBits == obj.numCarriers
		    padBits = 0;
		end
		modData = [modData; step(obj.pMod,randi([0 1],padBits,1))];

		% Calculate required data sizes for correct receiver operation
		numDataSymbols = length(modData)/obj.numCarriers;
		numSamples = length(modData);
		messageCharacters = length(payloadMessage); % Save desired message size
		%numFrames = numFrames; % Save number of transmitted frames

		% Convert data into subcarrier streams
		ofdmData = reshape(modData.', obj.numCarriers, length(modData)/obj.numCarriers);
		
		% Modulate
		obj.hDataMod.NumSymbols = numDataSymbols;
		r = step(obj.hDataMod, ofdmData, obj.pilots);

		% Add preambles to data
		preambles = [obj.CompleteShortPreambleOFDM; obj.CompleteLongPreambleOFDM];
		r = [preambles; r];
		frameLength = length(r);

		% Repeat frame (Used in debugging)
		%r = repmat(r, numFrames, 1);
		frame = r;

	end

    end
end
