function coefs = linearregression(obs,model)
  idx         = isnan(obs) | isnan(model);
  obs(idx)    = [];
  model(idx)  = [];
  % [obs, I]    = sort(obs);
  % I
  % model       = model(I);
  coefs       = polyfit(obs, model, 1);
end