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

    hours = time_int // 100
    mins  = time_int % 100

    valid = (hours >= 0) & (hours <= 23) & (mins >= 0) & (mins <= 59)

    mins = mins.astype("float64").where(valid, np.nan)
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

    if parts.shape[1] > 2:
        secs = pd.to_numeric(parts[2], errors="coerce")
    else:
        secs = pd.Series(0, index=time.index, dtype="float64")

    valid = (
        (hours >= 0) & (hours <= 23) &
        (mins  >= 0) & (mins  <= 59) &
        (secs  >= 0) & (secs  <= 59)
    )

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
    
    arr = actual.to_numpy()
    pos = np.searchsorted(scheduled, arr)

    left_idx = np.clip(pos - 1, 0, len(scheduled) - 1)
    right_idx = np.clip(pos, 0, len(scheduled) - 1)
    left_vals = scheduled[left_idx]
    right_vals = scheduled[right_idx]

    left_dist = np.abs(arr - left_vals)
    right_dist = np.abs(right_vals - arr)
    choose_right = right_dist < left_dist
    matched = np.where(choose_right, right_vals, left_vals).astype('int64')
    
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
    
    df = assigned_scheduled_times

    if {'Arrival Times', 'Scheduled Times'}.issubset(df.columns):
        actual_raw = pd.to_numeric(df['Arrival Times'],    errors='coerce')
        scheduled_raw = pd.to_numeric(df['Scheduled Times'],  errors='coerce')
    else:
        scheduled_raw = pd.to_numeric(df.iloc[:, 0], errors='coerce')
        actual_raw = pd.to_numeric(df.iloc[:, 1], errors='coerce')

    scheduled_hms = pd.Series(np.nan, index=scheduled_raw.index, dtype="object")
    remove_na_scheduled = scheduled_raw.notna()
    four_digits_scheduled = scheduled_raw[remove_na_scheduled].astype(int).astype(str).str.zfill(4)
    scheduled_hms.loc[remove_na_scheduled] = four_digits_scheduled.str.slice(0, 2) + ":" + four_digits_scheduled.str.slice(2, 4) + ":00"

    actual_hms = pd.Series(np.nan, index=actual_raw.index, dtype="object")
    remove_na_actual = actual_raw.notna()
    four_digits_actual = actual_raw[remove_na_actual].astype(int).astype(str).str.zfill(4)
    actual_hms.loc[remove_na_actual] = four_digits_actual.str.slice(0, 2) + ":" + four_digits_actual.str.slice(2, 4) + ":00"

    scheduled_min = convert_to_minofday(scheduled_hms)
    actual_min = convert_to_minofday(actual_hms)

    delay = actual_min - scheduled_min
    delay = np.where(delay < 0, delay + 1440, delay)
    delay = pd.Series(delay, index=actual_min.index, dtype="float64")

    return delay.astype(float)
