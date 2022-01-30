<h1>A Network block device server using the sia storage network as backend</h1>

<p><b>All credits for the original app go to javgh. Visit their Github for more in-depth information: <a href="https://github.com/javgh/sia-nbdserver">https://github.com/javgh/sia-nbdserver</a></b></p>
<p><b>Use at your own risk! You could loose your data or spend a lot of siacoin using this!</b></p>
<p>This container will run an nbd-server that listens on port 10809 for connections from an nbd-client essentially mounting files stored on the sia storage network locally. It writes data in page files that are later pushed to sia when they become inactive. This happens transparently so the stored files are available regardless whether they are still cached locally or already uploaded to sia.</p>

<h3>Requirements</h3>

<p>An instance of sia with the renter module loaded, synced blockchain, unlocked wallet, configured allowance and siacoin to spend. To mount the device you need the kernel module <code>nbd</code> loaded and the package <code>nbd-client</code>.</p>

<h3>Docker</h3>

<pre><code>docker run -d \
    --name sia-nbdserver \
    -e SIA_API_ADDRESS= \
    -p 10809:10809 \
    -v /path/to/cache:/cache \
    -v /path/to/data:/data \
    jesta030/sia-nbdserver</code></pre>

<table>
  <tr>
    <th>Option</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>-e SIA_API_ADDRESS</td>
      <td>Adress and port to reach your sia instances' API.<br><code>Default: 127.0.0.1:9980</code></td>
  </tr>
  <tr>
    <td>-e PAGE_LIMIT_HARD</td>
      <td>Hard Limit for how many pages sia-nbdserver can write to cache.<br><code>Default: 128 (8GB)</code></td>
  </tr>
  <tr>
    <td>-e PAGE_LIMIT_SOFT</td>
    <td>Soft Limit for how many page files sia-nbdserver keeps cached. When surpassing this limit write throttling gradually takes effect.<br><code>Default: 96</code></td>
  </tr>
  <tr>
    <td>-e PAGE_IDLE</td>
    <td>How long pages need to be idle to be uploaded to the sia network.<br><code>Default: 120s</code></td>
  </tr>
  <tr>
    <td>-e DEV_SIZE</td>
    <td>Size of the mounted network block device. Should ideally be a multiple of 2^26 (=67108864).<br><code>Default: 1099511627776 (1TB)</code></td>
  </tr>
  <tr>
    <td>-v /path/to/cache:/cache</td>
    <td>Location on the host to cache page files before uploading or after downloading.<br>See limitations below.</td>
  </tr>
  <tr>
    <td>-v /path/to/data:/data</td>
    <td>Location of sia`s "apipassword" file. This file needs to be protected.<br><code>chmod 600</code></td>
  </tr>
</table>

<p>A word about security: Don't expose sia's API port. And especially don't run sia with <code>--disable-API-security</code>. There are two ways of securely communicating with sia's API: use docker-compose to run both sia and sia-nbdserver in one container or put both containers on the same docker network without exposing sia's API port.</p>

<h3>Host</h3>

<ul><li><code>$ modprobe nbd</code> - Load the nbd kernel module.
<li><code>$ nbd-client -b 4096 -t 3600 $SERVER_ADDRESS $DEVICE</code> - Connect to the nbd-server where $SERVER_ADDRESS is the server's address and port and $DEVICE is an available nbd device like /dev/nbd0.
<li><code>$ mkfs.xfs $DEVICE</code> - Create file system (XFS in this case). 
<li><code>$ mount -o sync $DEVICE $PATH</code> - Mount $DEVICE at $PATH.</ul>

<h3>Limitations</h3>

<ul><li>Changing a small file results in a whole page of 64MB being rewritten and later uploaded - at 3x redundancy (sia default) that's 192MB bandwidth used that needs to be paid for. That's why this server should be used with caution and mainly for backups and large files.
<li>The server will by default keep up to 128 pages of 64MB each in the cache. If you don't mount a volume to /cache they are stored in memory resulting in a whopping 8GB of memory usage. Data stored in memory and not already pushed to the sia network will be lost when stopping the container.</ul>

<h4>Version history</h4>

<ul>
<li>0.3: implement more options through environmental variables
<li>0.2: implement caching to disk
<li>0.1: initial push</ul>
