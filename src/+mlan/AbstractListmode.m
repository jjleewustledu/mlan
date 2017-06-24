classdef AbstractListmode < mlan.AbstractIO
	%% ABSTRACTLISTMODE  

	%  $Revision$
 	%  was created 22-Jun-2017 21:16:07 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/Local/src/mlcvl/mlan/src/+mlan.
 	%% It was developed on Matlab 9.2.0.538062 (R2017a) for MACI64.  Copyright 2017 John Joowon Lee.
 	
	properties
 		
 	end

	methods (Static)
        function obj = hex2ulong(obj)
            assert(ischar(obj));
            obj = uint32(hex2dec(obj));
        end 
        function obj = ulong(obj)
            %% ULONG always returns unit32 (4-byte unsigned integer)
            
            if (ischar(obj))
                obj = uint32(str2double(obj));
            end
            if (isfloat(obj))
                obj = uint32(obj);
            end
        end
        function t   = total(arr)
            t = sum(reshape(arr, 1, []));
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

