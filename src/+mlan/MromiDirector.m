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
            assert(~isempty(this.sessionData_));
            g = this.sessionData_;
        end
    end
    
	methods 
		  
 		function this = MromiDirector(varargin)
 			%% MROMIDIRECTOR
 			%  Usage:  this = MromiDirector()

 			ip = inputParser;
            addParameter(ip, 'sessionData', [], @(x) isa(x, 'mlpipeline.ISessionData'));
            parse(ip, varargin{:});
            
            this.sessionData_ = ip.Results.sessionData;
        end
        
        function obj  = construct(this, varargin)
        end
        function oef  = constructOefAtlas(this)
        end
        function oef  = constructOefMap(this)
        end
        function map  = constructPetObsMap(this, varargin)
            %% CONSTRUCTPETOBSMAP
            %  returns pet, an mlpet.PETImagingContext
            
            ip = inputParser;
            addParameter(ip, 'sessionData', this.sessionData, @(x) isa(x, 'mlpipeline.ISessionData'));
            parse(ip, varargin{:});            
            this.sessionData_ = ip.Results.sessionData;
            
            mmrb = mlfourdfp.MMRBuilder('sessionData', this.sessionData);
            mmrb = mmrb.buildPetObsMap;
            map  = mmrb.product;
        end
        function map  = constructCbfMap(this, varargin)
            import mlpet.*;
            sessd = this.sessionData;
            sessd.vnumber = 1;
            sessd.snumber = 1;
            sessd.tracer  = 'HO';
            
            obsB = this.constructPetObsMap(varargin{:});
            
            artB = ArterialSamplingBuilder('sessionData', sessd);
            artB = artB.buildArterialSampling;
            
            cbfB = CbfBuilder('sessionData', sessd);
            cbfB = cbfB.buildCbfMap(obsB.product, artB.product);
            map  = cbfB.product;
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

