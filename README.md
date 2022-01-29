<h1>A Network block device server using the sia storage network as backend</h1>

<p><b>All credits for the original app go to javgh. Visit their Github for more in-depth information: <a href="https://github.com/javgh/sia-nbdserver">https://github.com/javgh/sia-nbdserver</a></br>
Use at your own risk! You could loose your data or spend a lot of siacoin using this!</b></p>
<p>This container will run an nbd-server that listens on port 10809 for connections from an nbd-client essentially mounting files stored on the sia storage network locally. It writes data in page files that are pushed to sia when they become inactive. This happends transparently so the stored files are available regardless whether they are still cached locally or already uploaded to sia.</p>

<h3>Requirements</h3>

<p>An instance of siad with the renter module loaded, synced blockchain, unlocked wallet, configured allowance and siacoin to spend.</p>

<h3>Usage</h3>

<h4>Docker</h4>

<pre><code>docker run -d \
    --name sia-nbdserver \
    --network \
    -e SIA_API_ADDRESS= \
    -p 10809:10809 \
    -v /path/to/cache:/cache \
    -v /path/to/data:/data \
    jesta030/sia-nbdserver</code></pre>

<ul><li><b>--network:</b> I recommend running sia-nbdserver and siad as separate containers on the same docker network. This way you don't need to expose siad's API port 
<li><b>-e SIA_API_ADDRESS:</b> Address and Port of the sia API.
<li><b>-v /path/one:/cache:</b> Volume for caching to disk. If omitted cache is stored in memory only!
<li><b>-v /path/two:/data:</b> This volume needs to contain a file called "apipassword" that contains sia's API password. This file needs to be well protected (<code>chmod 600</code>).</ul>

<h4>Host</h4>

<ul><li>Load the nbd kernel module: <code>modprobe nbd</code>
<li>Connect: <code>nbd-client -b 4096 -t 3600 $SERVER_ADDRESS $DEVICE</code> where $SERVER_ADDRESS is the sia-nbdserver's address and port and $DEVICE is an available nbd device like /dev/nbd0
<li>Create file system: <code>mkfs.xfs $DEVICE</code> 
<li>Mount $DEVICE at $PATH: <code>mount -o sync $DEVICE $PATH</code></ul>

<h3>Limitations</h3>

<ul><li>Changing a small file results in a whole page of 64MB being rewritten and later uploaded - at 3x redundancy (sia default) that's 192MB bandwidth used that needs to be paid for. That's why this server should be used with caution and mainly for backups and large files.
<li>The server will keep up to 128 pages of 64MB each. If you don't mount a volume to /cache they are stored in memory resulting in a whopping 8GB of memory usage. Data stored in memory and not already pushed to the sia network will be deleted when stopping the container.</ul>

<h3>Version history</h3>

<ul><li>0.2: implement caching to disk
<li>0.1: initial push</ul>
