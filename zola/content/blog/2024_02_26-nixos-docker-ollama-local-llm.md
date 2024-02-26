+++
title = "NixOS - running LLM locally using ollama and Docker"
date = 2024-02-26
+++

[Ollama is now available as an official Docker image](https://ollama.com/blog/ollama-is-now-available-as-an-official-docker-image), so we can run it on any machine with docker installed. Since I have an NVIDIA RTX 2070 SUPER I would like to use the GPU to accelerate the LLM to be blazingly fast. First we need to enable proprietary NVIDIA drivers on NixOS machine in `configuration.nix`:
```
  # Enable Nvidia and OpenGL
  hardware = common.hardware // {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };
  services = common.services // {
    xserver = common.services.xserver // {
      videoDrivers = [ "nvidia" ];
    };
  };
```

Then we need to also enable Docker with NVIDIA support enabled in `configuration.nix`:
```
  # nvidia docker
  virtualisation = {
    docker = {
      enable = true;
      enableNvidia = true;
    };
  };
```

Now we need to rebuild the system with `nixos-rebuild switch` to apply the changes to the NixOS system. After successful install I **recommend rebooting the machine**. After reboot we can test if the NVIDIA drivers are working using `nvidia-smi` command:
```
+---------------------------------------------------------------------------------------+
| NVIDIA-SMI 545.29.02              Driver Version: 545.29.02    CUDA Version: 12.3     |
|-----------------------------------------+----------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |         Memory-Usage | GPU-Util  Compute M. |
|                                         |                      |               MIG M. |
|=========================================+======================+======================|
|   0  NVIDIA GeForce RTX 2070 ...    Off | 00000000:01:00.0  On |                  N/A |
| 24%   30C    P8              23W / 215W |    649MiB /  8192MiB |      8%      Default |
|                                         |                      |                  N/A |
+-----------------------------------------+----------------------+----------------------+
```

Seems to be working so we can pull the ollama container and run it with NVIDIA GPU support:
```
docker run -d --gpus=all -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama
```

Now you can run any LLM model from [ollama model library](https://ollama.com/library), for example mistral:
```
$ docker exec -it ollama ollama run mistral
>>> What is 1 + 1? Answer only.
 The answer to the expression "1 + 1" is 2.
```

