function [] = imsave(image, filename)
  save_path = 'outputs/imgs/';
  save_format = 'png';
  save_unique = datestr(now,'yyyy-mm-dd.HH-MM-SS');
  filepath = strcat(save_path, save_unique, '.', filename, '.', save_format);
  % imwrite(image, filepath);
end