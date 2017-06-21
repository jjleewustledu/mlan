classdef ISortLMMotionMatlab 
	%% ISORTLMMOTIONMATLAB  

	%  $Revision$
 	%  was created 16-Jun-2017 00:51:18 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/Local/src/mlcvl/mlan/src/+mlan.
 	%% It was developed on Matlab 9.2.0.538062 (R2017a) for MACI64.  Copyright 2017 John Joowon Lee.
 	
	properties (Abstract)
        
        % provided to class constructor
        
        listmodeFileprefix % of native listmode on filesystem to be used with filetypes '.bf' and '.dcm'
        consecutiveDurationTime % scalar or vector time in ms for initial binning of listmode
 	end

	methods (Abstract)
        this = rebinListmode(this, mrDerivedBinIndex)
        %% REBINLISTMODE
        %  @params mrDerivedBinIndex is integer, either:  
        %   scalar -> rebin listmode to time frames of duration mrDerivedBinIndex*this.consecutiveDurationTime or
        %   vector -> rebin listmode to time frames of duration mrDerivedBinIndex.*this.consecutiveDurationTime.
        %   If M := mod(length(initial binning), length(requested rebinning)) > 0, 
        %   last time frame will have duration M*this.consecutiveDurationTime.
        %  @returns this containing rebinned listmode in memory.
        %  @throws mlan:unsupportedBinIndex
        
        sino = getSinogram(this)
        %% GETSINOGRAM
        %  @returns sinogram based on current listmode data in memory.
        
        this = revertListmode(this)
        %% REVERTLISTMODE
        %  @returns this with original listmode specified to constructor, discarding all previous actions of
        %  rebinListmode. 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

