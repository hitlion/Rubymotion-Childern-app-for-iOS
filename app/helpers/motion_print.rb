# Promotion ditched their logger in favor of
# MotionPrint.. add some helpers to ease life
def mp_l( message )
  mp "[INFO] #{message}", force_color: :green
end

def mp_d( message )
  mp "[DEBUG] #{message}", force_color: :yellow
end

def mp_e( message )
  mp "[ERROR] #{message}", force_color: :red
end
