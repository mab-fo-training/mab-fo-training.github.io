#!/usr/bin/env python3
"""
SharePoint Connection Test using Device Code Flow
Tests if your user account has proper permissions to the SharePoint site.
"""

import urllib.request
import urllib.parse
import json
import time
import sys

# Configuration
CLIENT_ID = "82a4ec5a-d90d-4957-8021-3093e60a4d70"
TENANT_ID = "8fc3a567-1ee8-4994-809c-49f50cdb6d48"
SITE_URL = "https://mabitdept.sharepoint.com/sites/FLTOPS-TRAINING"
LIST_NAME = "Training_Progress"

# SharePoint scope
SCOPE = "https://mabitdept.sharepoint.com/.default"

def get_device_code():
    """Request device code for authentication"""
    url = f"https://login.microsoftonline.com/{TENANT_ID}/oauth2/v2.0/devicecode"
    data = urllib.parse.urlencode({
        "client_id": CLIENT_ID,
        "scope": SCOPE
    }).encode()

    req = urllib.request.Request(url, data=data)
    with urllib.request.urlopen(req) as response:
        return json.loads(response.read())

def poll_for_token(device_code, interval, expires_in):
    """Poll for token after user authenticates"""
    url = f"https://login.microsoftonline.com/{TENANT_ID}/oauth2/v2.0/token"
    data = urllib.parse.urlencode({
        "client_id": CLIENT_ID,
        "grant_type": "urn:ietf:params:oauth:grant-type:device_code",
        "device_code": device_code
    }).encode()

    start_time = time.time()
    while time.time() - start_time < expires_in:
        time.sleep(interval)
        try:
            req = urllib.request.Request(url, data=data)
            with urllib.request.urlopen(req) as response:
                return json.loads(response.read())
        except urllib.error.HTTPError as e:
            error_data = json.loads(e.read())
            if error_data.get("error") == "authorization_pending":
                print(".", end="", flush=True)
                continue
            elif error_data.get("error") == "slow_down":
                interval += 5
                continue
            else:
                raise
    raise Exception("Authentication timed out")

def test_sharepoint_connection(access_token):
    """Test SharePoint connection with the access token"""

    # Test 1: Get site info
    print("\n\n[Test 1] Getting site info...")
    site_api = f"{SITE_URL}/_api/web"
    req = urllib.request.Request(site_api, headers={
        "Authorization": f"Bearer {access_token}",
        "Accept": "application/json;odata=verbose"
    })

    try:
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read())
            print(f"  ✅ Site Title: {data['d']['Title']}")
    except urllib.error.HTTPError as e:
        print(f"  ❌ Error {e.code}: {e.reason}")
        if e.code == 403:
            print("  → You don't have permission to access this site")
        return False

    # Test 2: Get list info
    print("\n[Test 2] Getting list info...")
    list_api = f"{SITE_URL}/_api/web/lists/getbytitle('{LIST_NAME}')"
    req = urllib.request.Request(list_api, headers={
        "Authorization": f"Bearer {access_token}",
        "Accept": "application/json;odata=verbose"
    })

    try:
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read())
            print(f"  ✅ List found: {data['d']['Title']}")
            print(f"  ✅ Item count: {data['d']['ItemCount']}")
    except urllib.error.HTTPError as e:
        print(f"  ❌ Error {e.code}: {e.reason}")
        if e.code == 404:
            print(f"  → List '{LIST_NAME}' not found. Create it first.")
        return False

    # Test 3: Try to read items
    print("\n[Test 3] Reading list items...")
    items_api = f"{SITE_URL}/_api/web/lists/getbytitle('{LIST_NAME}')/items?$top=5"
    req = urllib.request.Request(items_api, headers={
        "Authorization": f"Bearer {access_token}",
        "Accept": "application/json;odata=verbose"
    })

    try:
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read())
            items = data['d']['results']
            print(f"  ✅ Can read items: {len(items)} items retrieved")
    except urllib.error.HTTPError as e:
        print(f"  ❌ Error {e.code}: {e.reason}")
        return False

    # Test 4: Check write permission (get form digest)
    print("\n[Test 4] Checking write permission...")
    context_api = f"{SITE_URL}/_api/contextinfo"
    req = urllib.request.Request(context_api, data=b"", headers={
        "Authorization": f"Bearer {access_token}",
        "Accept": "application/json;odata=verbose"
    })

    try:
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read())
            print(f"  ✅ Write permission confirmed (form digest obtained)")
    except urllib.error.HTTPError as e:
        print(f"  ❌ Error {e.code}: Cannot get write permission")
        return False

    return True

def main():
    print("=" * 50)
    print("SharePoint Connection Test")
    print("=" * 50)
    print(f"\nSite: {SITE_URL}")
    print(f"List: {LIST_NAME}")
    print(f"Client ID: {CLIENT_ID}")

    # Step 1: Get device code
    print("\n[Step 1] Requesting device code...")
    try:
        device_info = get_device_code()
    except Exception as e:
        print(f"❌ Failed to get device code: {e}")
        sys.exit(1)

    # Step 2: Show user instructions
    print("\n" + "=" * 50)
    print("ACTION REQUIRED")
    print("=" * 50)
    print(f"\n{device_info['message']}")
    print(f"\nCode: {device_info['user_code']}")
    print("\nWaiting for authentication", end="", flush=True)

    # Step 3: Poll for token
    try:
        token_response = poll_for_token(
            device_info['device_code'],
            device_info.get('interval', 5),
            device_info['expires_in']
        )
    except Exception as e:
        print(f"\n❌ Authentication failed: {e}")
        sys.exit(1)

    print("\n✅ Authentication successful!")

    # Step 4: Test SharePoint connection
    print("\n" + "=" * 50)
    print("Testing SharePoint Connection")
    print("=" * 50)

    success = test_sharepoint_connection(token_response['access_token'])

    print("\n" + "=" * 50)
    if success:
        print("✅ ALL TESTS PASSED - SharePoint connection working!")
        print("=" * 50)
        print("\nYou can now use the application to manage training data.")
        print("Next step: Run data migration from Google Sheets")
    else:
        print("❌ SOME TESTS FAILED")
        print("=" * 50)
        print("\nCheck the errors above and verify:")
        print("1. Your account has Site Owner permissions")
        print("2. The Training_Progress list exists")
        print("3. Wait a few minutes if permissions were just granted")

if __name__ == "__main__":
    main()
