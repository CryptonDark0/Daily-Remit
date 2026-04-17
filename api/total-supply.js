export default async function handler(req, res) {
  const contract = "0x316a5e1F7d3a52083185261965685c15Ae284627";
  const key = "QI725NCCDY2DB13DTFW8H5P9EJNQT1CG3X";

  const url = `https://api.bscscan.com/api?module=stats&action=tokenSupply&contractaddress=${contract}&apikey=${key}`;

  try {
    const resp = await fetch(url);
    const data = await resp.json();

    if (data.status === "1") {
      const supply = Number(data.result) / 1e18;
      res.status(200).send(Math.round(supply).toString());
    } else {
      res.status(500).send("Error fetching supply");
    }
  } catch (error) {
    res.status(500).send("Server error");
  }
}
