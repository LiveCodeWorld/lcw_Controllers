script "ccc_video.lc"
command index
   put $_POST_RAW into rawPost
   ccc_ProcessDrop rawPost
end index
