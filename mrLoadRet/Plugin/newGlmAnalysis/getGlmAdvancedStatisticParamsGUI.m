% getGlmAdvancedStatisticParamsGUI.m
%
%        $Id: getGlmAdvancedStatisticParamsGUI.m 2013 2011-01-21 17:43:19Z julien $
%      usage: params = getGlmAdvancedStatisticParamsGUI(params,useDefault)
%         by: julien besle, 
%       date: 19/01/2011
%    purpose: returns additional statistical test parameters for GLM analysis
%

function params = getGlmAdvancedStatisticParamsGUI(thisView,params,useDefault)

keepAsking = 1;

while keepAsking
  %Default params
  if fieldIsNotDefined(params, 'testOutput')
      params.testOutput = 'Z value';
  end
  if fieldIsNotDefined(params,'outputStatistic')
    params.outputStatistic = 0;
  end

  if fieldIsNotDefined(params, 'bootstrapIntervals')
      params.bootstrapIntervals = 0;
  end
  if fieldIsNotDefined(params, 'alphaConfidenceIntervals')
      params.alphaConfidenceIntervals = 0.05;
  end
  
  if fieldIsNotDefined(params, 'resampleFweMethod')
    params.resampleFweMethod = 'Step-down';
  end
  
  if fieldIsNotDefined(params, 'fweAdjustment')
      params.fweAdjustment = 0;
  end
  if fieldIsNotDefined(params, 'fweMethod')
      params.fweMethod = 'Step-down (Holm)';
  end
  
  if fieldIsNotDefined(params, 'fdrAdjustment')
      params.fdrAdjustment = 0;
  end
  if fieldIsNotDefined(params, 'fdrAssumption')
      params.fdrAssumption = 'Independence/Positive dependence';
  end
  if fieldIsNotDefined(params, 'fdrMethod')
      params.fdrMethod = 'Step-up';
  end
  
  if fieldIsNotDefined(params, 'trueNullsEstimationMethod')
      params.trueNullsEstimationMethod = 'Adaptive';
  end
  if fieldIsNotDefined(params, 'trueNullsEstimationThreshold')
      params.trueNullsEstimationThreshold = .05;
  end
  
  testOutputMenu = putOnTopOfList(params.testOutput,{'P value','Z value','-log10(P) value'});
  resampleFweMethodMenu = putOnTopOfList(params.resampleFweMethod,{'Single-step','Adaptive Single-step','Step-down','Adaptive Step-down'});
  fdrAssumptionMenu = putOnTopOfList(params.fdrAssumption,{'Independence/Positive dependence','None'});
  fweMethodMenu = putOnTopOfList(params.fweMethod,{'Single-step (Bonferroni)','Adaptive Single-step','Step-down (Holm)','Adaptive Step-down','Step-up (Hochberg)','Hommel'});
  fdrMethodMenu = putOnTopOfList(params.fdrMethod,{'Step-up','Adaptive Step-up','Two-stage Adaptive Step-up','Adaptive Step-down','Multiple-stage Adaptive Step-up'});
  adaptiveFweMethodMenu = putOnTopOfList(params.trueNullsEstimationMethod,{'Adaptive','Fixed Threshold'});
  
  paramsInfo = {...
      {'testOutput', testOutputMenu,'type=popupmenu', 'Type of statistics for output overlay.  P: outputs the probability value associated with the statistic. p-values less than 1e-16 will be replaced by 0; Z: outputs standard normal values associated with probability p. Z values with a probability less than 1e-16 will be replaced by +/-8.209536145151493'},...
      {'outputStatistic', params.outputStatistic,'type=checkbox', ''},...
      {'bootstrapIntervals', params.bootstrapIntervals,'type=checkbox', 'Whether to compute Bootstrap confidence intervals for contrasts and parameter estimates'},...
      {'alphaConfidenceIntervals', params.alphaConfidenceIntervals,'contingent=bootstrapIntervals', 'minmax=[0 1]', 'Confidence Intervals will be computed as fractiles (alpha/2) and (1-alpha/2) of the bootstrap estimated null distribution'},...
      {'resampleFweMethod', resampleFweMethodMenu,'type=popupmenu', ''},...
      {'fweAdjustment', params.fweAdjustment,'type=checkbox', ''},...
      {'fweMethod', fweMethodMenu,'contingent=fweAdjustment','type=popupmenu', ''},...
      {'trueNullsEstimationMethod', adaptiveFweMethodMenu,'type=popupmenu', ''},...
      {'trueNullsEstimationThreshold', params.trueNullsEstimationThreshold, ''},...
      {'fdrAdjustment', params.fdrAdjustment,'type=checkbox', ''},...
      {'fdrAssumption', fdrAssumptionMenu,'contingent=fdrAdjustment','type=popupmenu', ''},...
      {'fdrMethod', fdrMethodMenu,'contingent=fdrAdjustment','type=popupmenu', ''},...
       };

  if ~params.showAdvancedStatisticMenu || useDefault
    tempParams = mrParamsDefault(paramsInfo);
  else
    tempParams = mrParamsDialog(paramsInfo,'Advanced Statistics Menu');
  end

  % user hit cancel
  if isempty(tempParams)
    params = tempParams;
    return;
  end
  
  params = mrParamsCopyFields(tempParams,params);
  
  if (params.computeTtests || params.numberFtests) && params.permutationTests && ...
      ischar(params.scanParams{params.scanNum(1)}.stimDuration) && strcmp(params.scanParams{params.scanNum(1)}.stimDuration,'fromFile')
    mrWarnDlg('(getTestParamsGUI) Permutation tests are not compatible with stimulus duration from log file','Yes');
  elseif params.TFCE && params.parametricTests && (params.bootstrapFweAdjustment || params.permutationFweAdjustment) && ismember(params.bootstrapFweMethod,{'Step-down','Adaptive Step-down'})
    mrWarnDlg('(getTestParamsGUI) Step-down resample-based FWE adjustment is not implemented for TFCE-transformed data','Yes');
  elseif params.TFCE && params.parametricTests && (params.bootstrapFweAdjustment || params.permutationFweAdjustment) && ismember(params.bootstrapFweMethod,{'Adaptive Single-step'})
    mrWarnDlg('(getTestParamsGUI) Adaptive resample-based FWE adjustment is not implemented for TFCE-transformed data','Yes');
  elseif params.fdrAdjustment && strcmp(params.fdrAssumption,'None') && ismember(params.fdrMethod,{'Adaptive Step-down','Multiple-stage Adaptive Step-up'})
    mrWarnDlg('(getTestParamsGUI) Multi-stage and Step-down adaptive FDR adjustments require the assumption that voxel are independent or positively correlated','Yes');
  else
    keepAsking = 0;
  end
  if keepAsking && useDefault
    params = [];
    return;
  end

end

