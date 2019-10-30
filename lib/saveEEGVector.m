% Save all files related to the eegvector
function saveEEGVector( pathOutput, iphase, EEGvector, EEGvectorFileName)
    save(sprintf('%s%s_p%i.mat', pathOutput, EEGvectorFileName, iphase),'EEGvector');
end

