classdef MromiDirector 
	%% MROMIDIRECTOR  

	%  $Revision$
 	%  was created 05-Jan-2017 13:47:41
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlan/src/+mlan.
 	%% It was developed on Matlab 9.1.0.441655 (R2016b) for MACI64.
 	

	properties (Dependent)
        sessionData
    end
    
    methods %% GET
        function g = get.sessionData(this)
            g = this.sessionData_;
        end
    end
    
	methods 
		  
 		function this = MromiDirector(varargin)
 			%% MROMIDIRECTOR
 			%  Usage:  this = MromiDirector()

 			ip = inputParser;
            addParameter(ip, 'sessionData', []);
            parse(ip, varargin{:});
            
            this.sessionData_ = ip.Results.sessionData;
        end
        
        function obj  = construct(this, varargin)
        end
        function oef  = constructOefAtlas(this)
        end
        function oef  = constructOefMap(this)
        end
        function obs  = constructPetObsMap(this, varargin)
            ip = inputParser;
            addParameter(ip, 'sessionData', this.sessionData);
            parse(ip, varargin{:}); 
            this.sessionData_ = ip.Results.sessionData;
            
            scanB = this.scannerBuilder(varargin{:});
            scanB = scanB.buildPetObsMap; 
            obs   = scanB.product;
        end
        function cbf  = constructCbfMap(this, varargin)
            import mlpet.*;
            ip = inputParser;
            addParameter(ip, 'sessionData', this.sessionData);
            parse(ip, varargin{:});            
            this.sessionData_ = ip.Results.sessionData;
            this.sessionData_.tracer = 'HO';
            
            artB = ArterialSamplingBuilder('sessionData', this.sessionData);
            artB = artB.buildAifData;
            
            scanB = ScannerBuilder('sessionData', this.sessionData);
            scanB = scanB.buildPetObsMap('aifData', artB.product);
            
            cbfB = CbfBuilder('sessionData', this.sessionData);
            cbfB = cbfB.buildHerscCbfMap(artB.product, scanB.product);
            cbf  = cbfB.product;
        end
        function cbv  = constructCbvMap(this)
        end
    end 
    
    %% PRIVATE
    
    properties (Access = private)
        sessionData_
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
end

