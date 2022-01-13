classdef AbstractIO < mlio.AbstractIO    
	%% ABSTRACTIO provides thin, minimalist methods for I/O.  Agnostic to all other object characteristics.
    
	%  $Revision$
 	%  was created $Date$
 	%  by $Author$, 
 	%  last modified $LastChangedDate$
 	%  and checked into repository $URL$, 
 	%  developed on Matlab 8.1.0.604 (R2013a)
 	%  $Id$

    properties (Constant)
        DEBUGGING = true
    end
    
    methods
        function fid  = fopen(this, varargin)
            ip = inputParser;
            addOptional(ip, 'fn', this.fqfilename, @ischar);
            addOptional(ip, 'perm', 'r', @ischar);
            parse(ip, varargin{:});            
            
            if (2 == exist(ip.Results.fn, 'file') && lstrfind(lower(ip.Results.perm), 'w'))
                movefile(fn, this.appendFileprefix(ip.Results.fn, ['_' mydatetimestr(now)]));
            end
            fid = fopen(ip.Results.fn, ip.Results.perm);
        end
        
        function this = AbstractIO(varargin)
            this = this@mlio.AbstractIO(varargin{:});
        end
    end
    
    %% PROTECTED
    
    methods (Static, Access = protected)
        function fn     = appendFileprefix(fn, suff)
            assert(2 == exist(fn, 'file'));
            assert(ischar(suff));
            [pth,fp,x] = fileparts(fn);
            fn = fullfile(pth, [fp suff x]);
        end
        function bn     = basename(fn)
            [pth,fp] = fileparts(fn);
            bn = fullfile(pth, strtok(fp, '.'));
        end
        function nbytes = dprintf(meth, obj, varargin)
            if isempty(getenv('DEBUG'))
                return
            end
            assert(ischar(meth));
            if (ischar(obj))
                if (~isempty(varargin))
                    obj = sprintf(obj, varargin{:});
                end
                nbytes = fprintf(sprintf('%s:  %s\n', meth, obj));
            elseif (isnumeric(obj))
                if (numel(obj) < 100)
                    nbytes = fprintf(sprintf('%s:  %s\n', meth, mat2str(obj)));
                else
                    obj = reshape(obj, 1, []);                    
                    nbytes = fprintf(sprintf('%s:  %s\n', meth, mat2str(obj(1:100))));
                end
            else
                try
                    nbytes = fprintf(sprintf('%s:  %s\n', meth, char(obj)));
                catch ME
                    error('mlan:unsupportedTypeclass', 'class(SortLMMotionMatlab.dprintf.obj) -> %s', class(obj));
                end
            end
        end       
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

