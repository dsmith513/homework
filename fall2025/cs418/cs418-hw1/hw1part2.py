import io, time, json
import requests
from bs4 import BeautifulSoup
from urllib.parse import urlparse, parse_qs

import base64

# 2% credit
def retrieve_html(url):
    """
    Return the raw HTML at the specified URL.

    Args:
        url (string): 

    Returns:
        status_code (integer):
        raw_html (string): the raw HTML content of the response, properly encoded according to the HTTP headers.
    """
    
    headers = {
        "User-Agent": ("Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                       "AppleWebKit/537.36 (KHTML, like Gecko) "
                       "Chrome/126.0 Safari/537.36"),
        "Accept-Language": "en-US,en;q=0.9",
    }
    
    response = requests.get(url, headers=headers)
    response.encoding = response.apparent_encoding

    return response.text

#3% credit
def parse_imdb(imdb_data):
    """
    Return the movie lists from imdb top chart URL.

    Args:
        raw_html (string): 

    Returns:
        movies (list): the list of movies with Title, Description and Rating.
    
        Example:
        movies = [
        {
            'Title': 'The Shawshank Redemption',
            'Description': 'A Maine banker convicted of the murder of his wife and her lover...',
            'Rating': 9.3,
        },
        {
            'Title': 'The Godfather',
            'Description': 'Don Vito Corleone, head of a mafia family, decides to hand over his empire...',
            'Rating': 9.2,

        },
            # ... more
        ]

    
    """

    soup = BeautifulSoup(imdb_data, "html.parser")
    movies = []

    blocks = soup.select("li.ipc-metadata-list-summary-item")
    for block in blocks:
        t = block.select_one("h3.ipc-title__text")
        if not t:
            continue
        title_text = t.get_text(strip=True)
        title = title_text.split(".", 1)[1].strip() if "." in title_text else title_text

        r = block.select_one("span.ipc-rating-star--rating")
        try:
            rating = float(r.get_text(strip=True)) if r else None
        except Exception:
            rating = None

        d = block.select_one("[data-testid='plot']")
        description = d.get_text(" ", strip=True) if d else ""

        if title and rating is not None:
            movies.append({"Title": title, "Description": description, "Rating": rating})

    return movies

# 1% credit
def read_api_key(filepath):
    """
    Read the Spotify API Keys from file.
    
    Args:
        filepath (string): File containing API Keys
    Returns:
        client_id (string): Your client id
        client_secret (string): Your client secret
    """
    
    # feel free to modify this function if you are storing the API Key differently
    with open(filepath, 'r') as file:
        return json.load(file)


# 2% credit
def access_spotify(client_id, client_secret):
    """
    Authenticates the user and retrieves the bearer token required for API requests.
    """
    
    auth_url = 'https://accounts.spotify.com/api/token'
    auth_header = base64.b64encode(f"{client_id}:{client_secret}".encode()).decode()

    headers = {
        'Authorization': f'Basic {auth_header}',
        'Content-Type': 'application/x-www-form-urlencoded',
    }
    data = {
        'grant_type': 'client_credentials'
    }
    
    response = requests.post(auth_url, headers=headers, data=data)
    access_token = response.json().get('access_token')
    
    return access_token

# 4% credit    
def spotify_search_params(client_id, client_secret, **kwargs):
    """
    Construct url, headers and params. Reference API docs (link above) to use the arguments
    """
    # What is the url endpoint for search?
    url = "https://api.spotify.com/v1/search"
    # How is Authentication performed? Hint: use access_token from function of access_spotify
    access_token = access_spotify(client_id, client_secret)
    headers = {"Authorization": f"Bearer {access_token}"}
    # SPACES in url is problematic. How should you handle queries with field filters?
    query = kwargs.get("q") or " ".join(
        f"{k}:{v}" for k, v in kwargs.items() if k in ("artist", "track", "album")
    ).strip()
    # Include keyword arguments in params dictionary
    params = {"q": query, "type": kwargs.get("type", "track")}
    params.update({k: v for k, v in kwargs.items() if k not in ["q", "type", "artist", "track", "album"]})

    return url, headers, params


# 2% credit
def api_get_request(url, headers, params):
    """
    Send a HTTP GET request and return a json response 
    
    Args:
        url (string): API endpoint url
        headers (dict): A python dictionary containing HTTP headers including Authentication to be sent
        url_params (dict): The parameters (required and optional) supported by endpoint
        
    Returns:
        results (json): response as json
    """
    # See requests.request?
    
    response = requests.request("GET", url, headers=headers, params=params)
    return response.json()
    

def spotify_search(client_id, client_secret, **kwargs):
    """
    Make an authenticated request to the Spotify API and return search results.

    Args:
        client_id (string): Your Spotify Client ID for Authentication
        client_secret (string): Your Spotify Client Secret for Authentication
        **kwargs: Additional search parameters (e.g., artist, track, album, etc.)

    Returns:
        total (integer): Total number of tracks matching the query
        tracks (list): List of dicts representing each track with name, and popularity
    """
    url, headers, params = spotify_search_params(client_id, client_secret, **kwargs)
    response_json = api_get_request(url, headers, params)

    tracks_section = response_json.get('tracks') or {}
    total = tracks_section.get('total', 0)
    items = tracks_section.get('items', []) or []

    tracks = []
    for track in items:
        tracks.append({
            'track_name': track.get('name'),
            'popularity': track.get('popularity', 0)
        })
    return total, tracks

# 4% credit
def paginated_spotify_search_requests(client_id, client_secret, artist_name, total,limit):
    """
    Returns a list of tuples (url, headers, params) for paginated search of all restaurants
    Args:
        client_id, client_secret (string): Your Spotify API Key for Authentication
        artist_name (string): Artist name
        total (int): Total number of items to be fetched
        limit (int): Number of items to fetch per request (default is 50)
    Returns:
        results (list): list of tuple (url, headers, params)
    """
    # HINT: Use total, offset and limit for pagination
    # You can reuse function location_search_params(...)
    results = []
    num_pages = total // limit

    for i in range(num_pages):
        offset = i * limit
        url, headers, params = spotify_search_params(
            client_id, client_secret,
            q=f'artist:{artist_name}',
            type='track',
            limit=limit,
            offset=offset
        )
        results.append((url, headers, params))

    return results


# 3% credit
def get_tracks(client_id, client_secret, artist_name):
    """
    Construct the pagination requests for ALL tracks by Given Artist on Spotify.

    Args:
        client_id (string): Your Spotify Client ID for Authentication
        client_secret (string): Your Spotify Client Secret for Authentication
        artist_name (string): Artist name

    Returns:
        results (list): List of dicts representing each track
    """
    total_items = 200
    limit = 50
    
    tracks_request = paginated_spotify_search_requests(client_id, client_secret, artist_name, total_items, limit)
    
    # Use returned list of (url, headers, url_params) and function api_get_request to retrive all restaurants
    # REMEMBER to pause slightly after each request.
    results = []
    for url, headers, params in tracks_request:
        page_json = api_get_request(url, headers, params)
        items = page_json.get('tracks', {}).get('items', [])
        for t in items:
            results.append({
                'track_name': t.get('name'),
                'album_name': t.get('album', {}).get('name'),
                'popularity': t.get('popularity', 0)
            })
        time.sleep(0.2)
        
    return results[:total_items]

# 4% credit
def parse_api_response(data):
    """
    Parse Spotify API results to extract cover images URLs.
    
    Args:
        data (string): String of properly formatted JSON.

    Returns:
        (list): list of URLs as strings from the input JSON.
    """
    
    songData = json.loads(data)
    urls = []

    if isinstance(songData, dict) and isinstance(songData.get('tracks'), dict):
        for item in songData['tracks'].get('items', []):
            for img in item.get('album', {}).get('images', []):
                if 'url' in img:
                    urls.append(img['url'])
    elif isinstance(songData, list):
        for item in songData:
            for img in item.get('album', {}).get('images', []):
                if 'url' in img:
                    urls.append(img['url'])
    elif isinstance(songData, dict):
        for img in songData.get('album', {}).get('images', []):
            if 'url' in img:
                urls.append(img['url'])

    return urls


def html_fetcher(url):
    """
    Return the raw HTML at the specified URL.
    Args:
        url (string): 

    Returns:
        status_code (integer):
        raw_html (string): the raw HTML content of the response, properly encoded according to the HTTP headers.
    """
    html_file = url_lookup.get(url)
    with open(html_file, 'rb') as file:
        html_text = file.read()
        return 200, html_text

# 11% credit
def parse_page(html):
    """
    Parse reviews from an IMDb movie reviews page.

    Args:
        html (string): HTML content of the IMDb reviews page.

    Returns:
        reviews (list): A list of dictionaries, each containing the review's rating, author, date, and content.
    """
    soup = BeautifulSoup(html,'html.parser')
    reviews_list = []

    # Find all review containers on the page
    review_containers = soup.find_all('div', class_='lister-item-content')
    # HINT: print reviews to see what http tag to extract
    for block in review_containers:
        author_tag = block.select_one('.display-name-link a')
        author = author_tag.get_text(strip=True) if author_tag else ""

        rating_tag = block.select_one('.rating-other-user-rating span')
        rating = float(rating_tag.get_text(strip=True)) if rating_tag else None

        date_tag = block.select_one('.review-date')
        date_text = date_tag.get_text(strip=True) if date_tag else ""
        text_tag = block.select_one('[data-testid="review-content"]')
        review_text = text_tag.get_text(" ", strip=True) if text_tag else ""

        reviews_list.append({
            'Author': author,
            'Rating': rating,
            'Date': date_text,
            'Review': review_text
        })
        
    return reviews_list
        
