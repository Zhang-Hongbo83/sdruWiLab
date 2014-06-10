function s = TuneResultCapiT()
%#codegen

%   Copyright 2011-2012 The MathWorks, Inc.

    s = struct( ...
        'targetIntermediateFrequency',  double(0), ...
        'actualIntermediateFrequency',  double(0), ...
        'targetDSPFrequency',           double(0), ...
        'actualDSPFrequency',           double(0)  ...
        );
end
