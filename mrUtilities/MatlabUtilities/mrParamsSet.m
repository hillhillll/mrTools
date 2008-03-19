% mrParamsSet.m
%
%        $Id$
%      usage: mrParamsSet(params)
%         by: justin gardner
%       date: 03/18/08
%    purpose: pass in params and this will reset the fields in an
%             open mrParamsDialog, useful for when you have a
%             non-modal dialog. Note that you do not have to havee
%             all the fields in the params structure, only the ones
%             you want to set
% 
%
function retval = mrParamsSet(params)

% check arguments
if ~any(nargin == [1])
  help mrParamsSet
  return
end

global gParams;


% go through each one of the passed in parameters
paramFields = fieldnames(params);
for fnum = 1:length(paramFields)
  % look for the parameter in varinfo
  match = 0;
  for vnum = 1:length(gParams.varinfo)
    if strcmp(paramFields{fnum},gParams.varinfo{vnum}.name)
      match = vnum;
    end
  end
  % found the match, go set the field
  if match
    % numeric
    if strcmp(gParams.varinfo{match}.type,'numeric')
      set(gParams.ui.varentry{match},'String',num2str(params.(paramFields{fnum})));
    % array
    elseif strcmp(gParams.varinfo{match}.type,'array')
      if isequal(size(gParams.varinfo{match}.value),size(params.(paramFields{fnum})))
	for matrixX = 1:size(params.(paramFields{fnum}),1)
	  for matrixY = 1:size(params.(paramFields{fnum}),2)
	    set(gParams.ui.varentry{match}(matrixX,matrixY),'String',num2str(params.(paramFields{fnum})(matrixX,matrixY)));
	  end
	end
      else
	disp(sprintf('(mrParamsSet) Array size of variable %s does not match',paramsFields{fnum}));
      end
    % popupmenu
    elseif strcmp(gParams.varinfo{match}.type,'popupmenu')
      value = find(strcmp(params.(paramFields{fnum}),gParams.varinfo{match}.value));
      if ~isempty(value)
	set(gParams.ui.varentry{match},'Value',value);
      else
	disp(sprintf('(mrParamsSet) %s is not a valid option for variable %s',params.(paramFields{fnum}),paramFields{fnum}));
      end
    % unimplemented type
    else
      disp(sprintf('(mrParamsSet) Setting of type %s not implemented yet',gParams.varinfo{match}.type));
    end
  else
    if ~strcmp(paramFields{fnum},'paramInfo')
      disp(sprintf('(mrParamsSet) Could not find var %s',paramFields{fnum}));
    end
  end
end

