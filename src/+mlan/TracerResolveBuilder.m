classdef TracerResolveBuilder < mlpet.TracerResolveBuilder
	%% TRACERRESOLVEBUILDER  

	%  $Revision$
 	%  was created 05-Nov-2019 20:16:22 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlan/src/+mlan.
 	%% It was developed on Matlab 9.7.0.1216025 (R2019b) Update 1 for MACI64.  Copyright 2019 John Joowon Lee.
 	
	properties
 		
 	end

	methods 
        function this = motionCorrectCTAndUmap(this)
            %% MOTIONCORRECTCTANDUMAP
            %  @param  this.sessionData is well-formed for the problem.
            %  @param  this.product is a single-epoch motion-corrected tracer.
            %          e.g., after completing this.motionCorrectFrames, 
            %          reconstitutedSummed.product := E1to9/fdgv1e1to9r2_op_fdgv1e1to9r1_frame9_sumt &&
            %          this := reconstitutedSummed.
            %  @return motion-corrections of umapSynth, T1, t2 onto this.product for 
            %          this.{compositeResolveBuilder,sessionData,product};
            %          e.g., this.product := umapSynth_to_op_fdgv1e1to9r1_frame9.
            
            import mlfourdfp.FourdfpVisitor
            pwd0 = pushd(this.product_.filepath);      
            this.locallyStageModalities( ...
                'fourdfp', this.sessionData.umapSynthOpT1001('typ', 'fqfp'));
            this.sessionData_.rnumber = 1;
            prodfp = this.product_.fileprefix; % 'ooe1to3r2_op_ooe1to3r1_frame3_avgt'
            try
                switch (this.sessionData_.tracer)
                    case  'OO'
                        imgs = {prodfp ... 
                                this.T1('typ', 'fp')};  
                        msks = {'Msktgen' 'T1001'}; 
                        cRB_ = mlfourdfp.CompositeT4ResolveBuilder( ...
                              'sessionData', this.sessionData_, ...
                              'theImages', imgs, ...
                              'blurArg', 6.5, ...
                              'maskForImages', msks, ...
                              'NRevisions', 1);
                    case {'HO' 'OC'}
                        imgs = {prodfp ... 
                                this.T1('typ', 'fp')};
                        msks = {'Msktgen' 'T1001'};
                        cRB_ = mlfourdfp.CompositeT4ResolveBuilder( ...
                              'sessionData', this.sessionData_, ...
                              'theImages', imgs, ...
                              'blurArg', 6.5, ...
                              'maskForImages', msks, ...
                              'NRevisions', 1);
                    otherwise
                        error('mlpet:IndexError', ...
                              'TracerResolveBuilder.motionCorrectCTAndUmap has no switch case for tracer->%s', ...
                              this.sessionData_.tracer);
                end
                cRB_ = cRB_.resolve;
                switch length(strfind(prodfp, '_'))
                    case 1
                        prodfp = cRB_.product{2}.fileprefix;
                        prodfp = strsplit(prodfp, '_op_');
                        prodfp = prodfp{2};
                    otherwise                        
                        prodfp = strsplit(prodfp, '_avgt');
                        prodfp = strsplit(prodfp{1}, '_op_');
                        prodfp = prodfp{2}; % 'ooe1to3r1_frame3'
                end
                copyfile( ...
                    [this.T1('typ','fp') 'r1_to_op_' prodfp '_t4'], ...
                    [this.sessionData.umapSynthOpT1001('typ', 'fp') 'r1_to_op_' prodfp '_t4'])
                fv = FourdfpVisitor;
                fv.t4img_4dfp( ...
                    [this.sessionData.umapSynthOpT1001('typ', 'fp') 'r1_to_op_' prodfp '_t4'], ...
                    this.sessionData.umapSynthOpT1001('typ', 'fp'), ...
                    'out', [this.sessionData.umapSynthOpT1001('typ', 'fp') 'r1_op_' prodfp], ...
                    'options', ['-O' this.product_.fileprefix]) 
                cRBProd = cRB_.product;
                cRBProd{end} = mlfourd.ImagingContext2([this.sessionData.umapSynthOpT1001('typ', 'fp') 'r1_op_' prodfp '.4dfp.hdr']);
                cRB_ = cRB_.packageProduct(cRBProd);
                % this.sessionData.umapSynthOpT1001('typ', 'fp') -> 'umapSynth_op_T1001_b43'                
            catch ME
                if (strcmp(ME.identifier, 'mlfourdfp:abnormalExit'))
                    imgs = {prodfp this.sessionData.umapSynthOpT1001('typ', 'fp')};
                    msks = {'none' 'none'};
                    cRB_ = mlfourdfp.CompositeT4ResolveBuilder( ...
                        'sessionData', this.sessionData_, ...
                        'theImages', imgs, ...
                        'blurArg', 8.6, ...
                        'maskForImages', msks, ...
                        'NRevisions', 1); 
                    cRB_ = cRB_.resolve;
                else
                    rethrow(ME)
                end
            end
                        
            % update this.{compositeResolveBuilder_,sessionData_,product_}   
            cRB_ = this.reconcileUmapFilenames(cRB_);
            this.compositeResolveBuilder_ = cRB_;
            this.sessionData_             = cRB_.sessionData;
            this.product_                 = cRB_.product;      
            this.product_.fourdfp;
            popd(pwd0);
        end
		  
 		function this = TracerResolveBuilder(varargin)
 			%% TRACERRESOLVEBUILDER
 			%  @param .

 			this = this@mlpet.TracerResolveBuilder(varargin{:});
 		end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

