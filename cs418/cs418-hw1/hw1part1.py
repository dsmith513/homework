import pandas as pd
import numpy as np

# 2% credit
def extract_hour(time):
    """
    Extracts hour information from military time
    
    Args: 
        time (float64): series of time given in military format.  
          Takes on values in 0.0-2359.0 due to float64 representation.
    
    Returns:
        array (float64): series of input dimension with hour information.  
          Should only take on integer values in 0-23
    """
    time_int = pd.to_numeric(time, errors="coerce").astype("Int64")
    hours = (time_int // 100).astype(float)
    hours = hours.where((hours >= 0) & (hours <= 23), np.nan)

    return hours

# 2% credit
def extract_mins(time):
    """
    Extracts minute information from military time
    
    Args: 
        time (float64): series of time given in military format.  
          Takes on values in 0.0-2359.0 due to float64 representation.
    
    Returns:
        array (float64): series of input dimension with minute information.  
          Should only take on integer values in 0-59
    """
    time_int = pd.to_numeric(time, errors="coerce").astype("Int64")
    mins = (time_int % 100).astype(float)
    mins = pd.Series(mins).where((mins >= 0) & (mins <= 59), np.nan)

    return mins

# 2% credit
def convert_to_minofday(time):
    """
    Converts HH:MM:SS time to minute of day
    
    Args:
        time: series of time given as strings in HH:MM:SS format.  
          
    
    Returns:
        array (float64): series of input dimension with minute of day
    
    Example: 13:03 is converted to 783.0
    """
    parts = time.str.split(":", expand=True)
    hours = pd.to_numeric(parts[0], errors="coerce")
    mins = pd.to_numeric(parts[1], errors="coerce")

    valid = (hours >= 0) & (hours <= 23) & (mins >= 0) & (mins <= 59)

    minofday = hours * 60 + mins
    minofday = minofday.where(valid, np.nan)

    return minofday.astype(float)

# 3%credit
def assigned_scheduled_times(arrival_times, scheduled_times):
    """
    Calculates delay times y - x
    
    Args:
        arrival_times: series of scheduled times 
        scheduled_times: series of actual arrival times
    
    Returns:
        arrival_scheduled_times: pandas dataframe with two columns viz., arrival times and corresponding scheduled time
    """
    
    actual = pd.Series(arrival_times, dtype='int64')

    # insert code to find the closest scheduled time for each arrival time in arrival_times
    scheduled = pd.Series(scheduled_times, dtype='int64').dropna().sort_values().to_numpy()
    idx = np.searchsorted(scheduled, actual.to_numpy(), side='right') - 1
    matched = np.where(idx >= 0, scheduled[np.clip(idx, 0, len(scheduled)-1)], np.nan)
    
    arrival_scheduled_times = pd.DataFrame({
        'Arrival Times': actual,
        'Scheduled Times': pd.Series(matched, index=actual.index, dtype='int64')
    })

    return arrival_scheduled_times

# 3% credit
def calc_delay(assigned_scheduled_times):
    """
    Calculates delay times y - x
    
    Args:
        assigned_scheduled_times: pandas dataframe with two columns viz., arrival times and corresponding scheduled time
    
    Returns: 
        pandas series of input dimension with delay time
    """
    
    scheduled = pd.to_numeric(assigned_scheduled_times.iloc[:, 0], errors='coerce')
    actual = pd.to_numeric(assigned_scheduled_times.iloc[:, 1], errors='coerce')
    
    delay = actual - scheduled
    return delay.astype(float)