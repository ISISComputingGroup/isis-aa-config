import mysql.connector
import aiohttp
import requests
import asyncio
import ast
import os

async def archivePV(url: str, session: aiohttp.ClientSession,) -> None:
    response = await session.request("GET", url=url)
    
    if response.status != 200:
        print(f"Could not archive: '{url}'.")

async def main():

    #should probably not hardcode this...
    iocdb = mysql.connector.connect(
        host="localhost",
        user=os.getenv("sql_iocdb_user"),
        password=os.getenv("sql_iocdb_pass")
    )

    ioccursor = iocdb.cursor()

    ioccursor.execute("SELECT iocdb.pvinfo.pvname, iocdb.pvinfo.value from iocdb.pvinfo where infoname = 'archive' group by iocdb.pvinfo.pvname")

    iocdb_pv_names = []
    iocdb_pv_value_types = []

    for result in ioccursor.fetchall():
        iocdb_pv_names.append(result[0])
        iocdb_pv_value_types.append(result[1])

    # The API endpoint
    url = "http://localhost:17665/mgmt/bpl/getAllPVs"

    # A GET request to the API
    response = requests.get(url)
    archive_pv_names = ast.literal_eval(response.text)

    async with aiohttp.ClientSession() as session:

        tasks = []

        for pv in iocdb_pv_names:
            
            if pv in archive_pv_names: continue

            url = f"http://localhost:17665/mgmt/bpl/archivePV?pv={pv}"
            tasks.append(archivePV(url=url,session=session))

        await asyncio.gather(*tasks, return_exceptions=True)

if __name__ == '__main__':
    
    asyncio.run(main())

# Next steps would be to make sure that any arguments that have been stored
# alongside val in iocdb get passed to archivePV in the appropriate ways
# e.g sample rate
# print(iocdb_pv_value_types) to see different stored args + value